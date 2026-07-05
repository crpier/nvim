#!/usr/bin/env node
/* eslint-disable no-console */

const fs = require("node:fs");
const net = require("node:net");
const os = require("node:os");
const path = require("node:path");
const readline = require("node:readline/promises");

function piConfigDir() {
  return process.env.PI_CODING_AGENT_DIR || path.join(os.homedir(), ".pi", "agent");
}

function bridgeDir() {
  return process.env.PI_BRIDGE_DIR || path.join(piConfigDir(), "agent-bridge");
}

function agentsDir() {
  return path.join(bridgeDir(), "agents");
}

function usage(exitCode = 0) {
  console.log(`Usage:
  pi-bridge list
  pi-bridge status [--agent <pid|socket>]
  pi-bridge send [--agent <pid|socket>] [--steer|--follow-up] [message]

Examples:
  pi -e ./pi-bridge/extension.ts --bridge
  pi-bridge list
  pi-bridge send "Summarize where we are"
  echo "Please continue" | pi-bridge send --follow-up
`);
  process.exit(exitCode);
}

function parseArgs(argv) {
  const args = [...argv];
  const command = args.shift();
  const options = { command, agent: undefined, deliverAs: "steer", messageParts: [] };

  while (args.length > 0) {
    const arg = args.shift();
    if (arg === "--agent" || arg === "-a") {
      options.agent = args.shift();
      if (!options.agent) throw new Error("--agent requires a pid or socket path");
    } else if (arg === "--steer") {
      options.deliverAs = "steer";
    } else if (arg === "--follow-up" || arg === "--followup") {
      options.deliverAs = "followUp";
    } else if (arg === "--help" || arg === "-h") {
      usage(0);
    } else {
      options.messageParts.push(arg);
      options.messageParts.push(...args);
      break;
    }
  }

  return options;
}

function isProcessAlive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

function loadAgents() {
  let files = [];
  try {
    files = fs.readdirSync(agentsDir());
  } catch (error) {
    if (error.code === "ENOENT") return [];
    throw error;
  }

  const agents = [];
  for (const file of files) {
    if (!file.endsWith(".json")) continue;
    const fullPath = path.join(agentsDir(), file);
    try {
      const agent = JSON.parse(fs.readFileSync(fullPath, "utf8"));
      const alive = Number.isInteger(agent.pid) && isProcessAlive(agent.pid);
      const socketExists = typeof agent.socketPath === "string" && fs.existsSync(agent.socketPath);
      if (alive && socketExists) {
        agents.push(agent);
      } else {
        try {
          fs.unlinkSync(fullPath);
        } catch {}
      }
    } catch {
      // Ignore malformed/stale registry files.
    }
  }

  return agents.sort((a, b) => String(a.startedAt).localeCompare(String(b.startedAt)));
}

function describeAgent(agent) {
  const name = agent.sessionName ? ` name=${JSON.stringify(agent.sessionName)}` : "";
  const session = agent.sessionFile ? ` session=${agent.sessionFile}` : " session=<ephemeral>";
  return `pid=${agent.pid}${name} cwd=${agent.cwd}${session}`;
}

function findAgent(agents, selector) {
  if (!selector) return undefined;
  const byPid = agents.find((agent) => String(agent.pid) === selector);
  if (byPid) return byPid;
  const bySocket = agents.find((agent) => agent.socketPath === selector);
  if (bySocket) return bySocket;
  if (fs.existsSync(selector)) return { pid: null, socketPath: selector, cwd: "", sessionFile: null, sessionName: null };
  throw new Error(`No running pi agent matches ${selector}`);
}

async function chooseAgent(selector) {
  const agents = loadAgents();
  if (selector) return findAgent(agents, selector);
  if (agents.length === 0) throw new Error("No running pi-bridge agents found. Start pi with: pi -e ./pi-bridge/extension.ts");
  if (agents.length === 1) return agents[0];

  console.log("Running pi agents:");
  agents.forEach((agent, index) => {
    console.log(`  ${index + 1}) ${describeAgent(agent)}`);
  });

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  try {
    const answer = await rl.question("Select agent: ");
    const index = Number(answer.trim()) - 1;
    if (!Number.isInteger(index) || index < 0 || index >= agents.length) {
      throw new Error("Invalid selection");
    }
    return agents[index];
  } finally {
    rl.close();
  }
}

function request(socketPath, payload) {
  return new Promise((resolve, reject) => {
    const socket = net.createConnection(socketPath);
    let buffer = "";

    socket.setEncoding("utf8");
    socket.on("connect", () => {
      socket.write(`${JSON.stringify(payload)}\n`);
    });
    socket.on("data", (chunk) => {
      buffer += chunk;
      const newline = buffer.indexOf("\n");
      if (newline === -1) return;
      const line = buffer.slice(0, newline).replace(/\r$/, "");
      socket.end();
      try {
        resolve(JSON.parse(line));
      } catch (error) {
        reject(error);
      }
    });
    socket.on("error", reject);
    socket.setTimeout(5000, () => {
      socket.destroy();
      reject(new Error("Timed out waiting for pi-bridge response"));
    });
  });
}

function stdinIsPiped() {
  return !process.stdin.isTTY;
}

async function readMessage(messageParts) {
  const inline = messageParts.join(" ").trim();
  if (inline) return inline;
  if (stdinIsPiped()) {
    return fs.readFileSync(0, "utf8").trim();
  }
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  try {
    return (await rl.question("Message: ")).trim();
  } finally {
    rl.close();
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  if (!options.command || options.command === "help") usage(0);

  if (options.command === "list") {
    const agents = loadAgents();
    if (agents.length === 0) {
      console.log("No running pi-bridge agents found.");
      return;
    }
    agents.forEach((agent, index) => console.log(`${index + 1}) ${describeAgent(agent)}`));
    return;
  }

  if (options.command === "status") {
    const agent = await chooseAgent(options.agent);
    const response = await request(agent.socketPath, { type: "status" });
    console.log(JSON.stringify(response, null, 2));
    process.exit(response.ok ? 0 : 1);
  }

  if (options.command === "send") {
    const message = await readMessage(options.messageParts);
    if (!message) throw new Error("Message is empty");
    const agent = await chooseAgent(options.agent);
    const response = await request(agent.socketPath, { type: "prompt", message, deliverAs: options.deliverAs });
    if (!response.ok) {
      console.error(response.error || JSON.stringify(response));
      process.exit(1);
    }
    console.log(`Sent to pid ${agent.pid} (${response.deliverAs}).`);
    return;
  }

  usage(1);
}

main().catch((error) => {
  console.error(`pi-bridge: ${error.message}`);
  process.exit(1);
});
