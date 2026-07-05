import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import fs from "node:fs";
import net from "node:net";
import os from "node:os";
import path from "node:path";

const BRIDGE_VERSION = 1;

type DeliveryMode = "steer" | "followUp";

type BridgeRequest =
	| { type: "ping" }
	| { type: "status" }
	| { type: "subscribe"; history?: boolean }
	| { type: "prompt"; message: string; deliverAs?: DeliveryMode };

type BridgeEvent =
	| { type: "subscribed"; agent: AgentRecord | undefined; idle: boolean | null }
	| { type: "history"; messages: SimpleMessage[] }
	| { type: "user"; text: string }
	| { type: "assistant_start" }
	| { type: "assistant_delta"; delta: string }
	| { type: "assistant_end" }
	| { type: "tool_start"; id: string; name: string; summary?: string }
	| { type: "tool_end"; id: string; name: string; ok: boolean }
	| { type: "agent_start" }
	| { type: "agent_end" };

type SimpleMessage = {
	role: "user" | "assistant" | "toolResult" | string;
	text: string;
	toolName?: string;
	isError?: boolean;
};

type AgentRecord = {
	version: number;
	pid: number;
	socketPath: string;
	cwd: string;
	mode: string;
	sessionFile: string | null;
	sessionName: string | null;
	startedAt: string;
	updatedAt: string;
};

function piConfigDir(): string {
	return process.env.PI_CODING_AGENT_DIR ?? path.join(os.homedir(), ".pi", "agent");
}

function bridgeDir(): string {
	return process.env.PI_BRIDGE_DIR ?? path.join(piConfigDir(), "agent-bridge");
}

function ensureDir(dir: string): void {
	fs.mkdirSync(dir, { recursive: true });
}

function safeUnlink(file: string): void {
	try {
		fs.unlinkSync(file);
	} catch (error) {
		if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
	}
}

function writeJsonAtomic(file: string, data: unknown): void {
	const tmp = `${file}.${process.pid}.tmp`;
	fs.writeFileSync(tmp, `${JSON.stringify(data, null, 2)}\n`, "utf8");
	fs.renameSync(tmp, file);
}

function contentToText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";

	return content
		.map((block) => {
			if (!block || typeof block !== "object") return "";
			const item = block as Record<string, unknown>;
			if (item.type === "text") return typeof item.text === "string" ? item.text : "";
			if (item.type === "thinking") return "";
			if (item.type === "image") return "[image]";
			if (item.type === "toolCall") return `[tool: ${String(item.name ?? "unknown")}]`;
			return "";
		})
		.filter(Boolean)
		.join("\n");
}

function messageToSimple(message: unknown): SimpleMessage | undefined {
	if (!message || typeof message !== "object") return undefined;
	const data = message as Record<string, unknown>;
	const role = typeof data.role === "string" ? data.role : "unknown";
	const text = contentToText(data.content);
	if (!text && role !== "toolResult") return undefined;
	return {
		role,
		text,
		toolName: typeof data.toolName === "string" ? data.toolName : undefined,
		isError: typeof data.isError === "boolean" ? data.isError : undefined,
	};
}

function parseLine(line: string): BridgeRequest {
	const parsed = JSON.parse(line) as Partial<BridgeRequest>;
	if (parsed.type === "ping" || parsed.type === "status") return parsed as BridgeRequest;
	if (parsed.type === "subscribe") return parsed as BridgeRequest;
	if (parsed.type === "prompt") {
		if (typeof parsed.message !== "string" || parsed.message.trim() === "") {
			throw new Error("prompt request requires a non-empty string message");
		}
		if (parsed.deliverAs !== undefined && parsed.deliverAs !== "steer" && parsed.deliverAs !== "followUp") {
			throw new Error('deliverAs must be "steer" or "followUp"');
		}
		return parsed as BridgeRequest;
	}
	throw new Error("unknown request type");
}

export default function (pi: ExtensionAPI) {
	const root = bridgeDir();
	const socketsDir = path.join(root, "sockets");
	const agentsDir = path.join(root, "agents");
	const socketPath = path.join(socketsDir, `pi-${process.pid}.sock`);
	const recordPath = path.join(agentsDir, `${process.pid}.json`);
	const startedAt = new Date().toISOString();

	let server: net.Server | undefined;
	let bridgeEnabled = false;
	let currentCtx: ExtensionContext | undefined;
	let currentRecord: AgentRecord | undefined;
	let assistantHadDelta = false;
	const subscribers = new Set<net.Socket>();

	function buildRecord(ctx: ExtensionContext): AgentRecord {
		return {
			version: BRIDGE_VERSION,
			pid: process.pid,
			socketPath,
			cwd: ctx.cwd,
			mode: ctx.mode,
			sessionFile: ctx.sessionManager.getSessionFile() ?? null,
			sessionName: pi.getSessionName() ?? null,
			startedAt,
			updatedAt: new Date().toISOString(),
		};
	}

	function publish(ctx: ExtensionContext): void {
		currentCtx = ctx;
		currentRecord = buildRecord(ctx);
		ensureDir(agentsDir);
		writeJsonAtomic(recordPath, currentRecord);
		ctx.ui.setStatus("pi-bridge", `bridge:${process.pid}`);
	}

	function send(socket: net.Socket, response: unknown): void {
		if (socket.destroyed || !socket.writable) return;
		socket.write(`${JSON.stringify(response)}\n`);
	}

	function broadcast(event: BridgeEvent): void {
		for (const subscriber of subscribers) {
			if (subscriber.destroyed || !subscriber.writable) {
				subscribers.delete(subscriber);
				continue;
			}
			send(subscriber, event);
		}
	}

	function historyMessages(ctx: ExtensionContext): SimpleMessage[] {
		return ctx.sessionManager
			.getBranch()
			.map((entry: unknown) => {
				const data = entry as { type?: string; message?: unknown };
				return data.type === "message" ? messageToSimple(data.message) : undefined;
			})
			.filter((message): message is SimpleMessage => message !== undefined);
	}

	async function handleRequest(request: BridgeRequest, socket: net.Socket): Promise<void> {
		if (request.type === "ping") {
			send(socket, { ok: true, type: "pong", pid: process.pid });
			return;
		}

		if (request.type === "status") {
			send(socket, {
				ok: true,
				type: "status",
				agent: currentRecord,
				idle: currentCtx?.isIdle() ?? null,
				hasPendingMessages: currentCtx?.hasPendingMessages() ?? null,
			});
			return;
		}

		if (request.type === "subscribe") {
			subscribers.add(socket);
			socket.once("close", () => subscribers.delete(socket));
			send(socket, { type: "subscribed", agent: currentRecord, idle: currentCtx?.isIdle() ?? null });
			if (request.history && currentCtx) {
				send(socket, { type: "history", messages: historyMessages(currentCtx) });
			}
			return;
		}

		if (!currentCtx) throw new Error("pi session is not ready yet");

		const deliverAs = request.deliverAs ?? "steer";
		pi.sendUserMessage(request.message, { deliverAs });
		publish(currentCtx);
		send(socket, {
			ok: true,
			type: "accepted",
			deliverAs,
			idle: currentCtx.isIdle(),
			hasPendingMessages: currentCtx.hasPendingMessages(),
		});
	}

	function startServer(ctx: ExtensionContext): void {
		bridgeEnabled = true;
		if (server) {
			publish(ctx);
			return;
		}

		ensureDir(socketsDir);
		ensureDir(agentsDir);
		safeUnlink(socketPath);

		server = net.createServer((socket) => {
			socket.setEncoding("utf8");
			let buffer = "";

			socket.on("data", (chunk) => {
				buffer += chunk;
				let newline = buffer.indexOf("\n");
				while (newline !== -1) {
					const line = buffer.slice(0, newline).replace(/\r$/, "");
					buffer = buffer.slice(newline + 1);
					if (line.trim()) {
						try {
							void handleRequest(parseLine(line), socket).catch((error: unknown) => {
								send(socket, { ok: false, error: error instanceof Error ? error.message : String(error) });
							});
						} catch (error) {
							send(socket, { ok: false, error: error instanceof Error ? error.message : String(error) });
						}
					}
					newline = buffer.indexOf("\n");
				}
			});

			socket.on("close", () => {
				subscribers.delete(socket);
			});

			socket.on("error", () => {
				// Clients may disconnect at any time. Nothing to do.
				subscribers.delete(socket);
			});
		});

		server.on("error", (error) => {
			ctx.ui.notify(`pi-bridge failed: ${error.message}`, "error");
		});

		server.listen(socketPath, () => {
			publish(ctx);
			ctx.ui.notify(`pi-bridge listening (${process.pid})`, "info");
		});
	}

	function stopServer(): void {
		bridgeEnabled = false;
		for (const subscriber of subscribers) {
			subscriber.destroy();
		}
		subscribers.clear();
		server?.close();
		server = undefined;
		safeUnlink(socketPath);
		safeUnlink(recordPath);
		currentRecord = undefined;
	}

	pi.registerFlag("bridge", {
		description: "Enable pi-bridge IPC for this session",
		type: "boolean",
		default: false,
	});

	pi.on("session_start", async (_event, ctx) => {
		currentCtx = ctx;
		if (pi.getFlag("bridge")) startServer(ctx);
	});

	pi.on("agent_start", async (_event, ctx) => {
		if (!bridgeEnabled) return;
		publish(ctx);
		broadcast({ type: "agent_start" });
	});

	pi.on("agent_end", async (_event, ctx) => {
		if (!bridgeEnabled) return;
		publish(ctx);
		broadcast({ type: "agent_end" });
	});

	pi.on("message_start", async (event) => {
		if (!bridgeEnabled) return;
		const message = (event as { message?: { role?: string } }).message;
		if (message?.role === "assistant") {
			assistantHadDelta = false;
			broadcast({ type: "assistant_start" });
		}
	});

	pi.on("message_update", async (event) => {
		if (!bridgeEnabled) return;
		const assistantEvent = (event as { assistantMessageEvent?: { type?: string; delta?: string } }).assistantMessageEvent;
		if (assistantEvent?.type === "text_delta" && typeof assistantEvent.delta === "string") {
			assistantHadDelta = true;
			broadcast({ type: "assistant_delta", delta: assistantEvent.delta });
		}
	});

	pi.on("message_end", async (event) => {
		if (!bridgeEnabled) return;
		const simple = messageToSimple((event as { message?: unknown }).message);
		if (!simple) return;

		if (simple.role === "user") {
			broadcast({ type: "user", text: simple.text });
			return;
		}

		if (simple.role === "assistant") {
			if (!assistantHadDelta && simple.text) {
				broadcast({ type: "assistant_delta", delta: simple.text });
			}
			broadcast({ type: "assistant_end" });
		}
	});

	pi.on("tool_execution_start", async (event) => {
		if (!bridgeEnabled) return;
		const data = event as { toolCallId?: string; toolName?: string; args?: unknown };
		broadcast({
			type: "tool_start",
			id: data.toolCallId ?? "unknown",
			name: data.toolName ?? "unknown",
			summary: data.args ? JSON.stringify(data.args).slice(0, 200) : undefined,
		});
	});

	pi.on("tool_execution_end", async (event) => {
		if (!bridgeEnabled) return;
		const data = event as { toolCallId?: string; toolName?: string; isError?: boolean };
		broadcast({
			type: "tool_end",
			id: data.toolCallId ?? "unknown",
			name: data.toolName ?? "unknown",
			ok: data.isError !== true,
		});
	});

	pi.on("session_shutdown", async () => {
		stopServer();
	});

	pi.registerCommand("bridge", {
		description: "Start, stop, or show pi-bridge IPC status",
		handler: async (args, ctx) => {
			const action = args.trim() || "status";

			if (action === "start" || action === "on" || action === "enable") {
				startServer(ctx);
				ctx.ui.notify(`pi-bridge enabled: ${socketPath}`, "info");
				return;
			}

			if (action === "stop" || action === "off" || action === "disable") {
				stopServer();
				ctx.ui.notify("pi-bridge disabled", "info");
				return;
			}

			if (action !== "status") {
				ctx.ui.notify("Usage: /bridge [start|stop|status]", "warning");
				return;
			}

			if (bridgeEnabled) {
				publish(ctx);
				ctx.ui.notify(`pi-bridge enabled: ${socketPath}`, "info");
			} else {
				ctx.ui.notify("pi-bridge disabled. Run /bridge start or launch pi --bridge.", "info");
			}
		},
	});
}
