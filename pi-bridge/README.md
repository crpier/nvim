# pi-bridge

Tiny first-pass IPC bridge for sending prompts to a running `pi` TUI session.

This is the base for a future Neovim integration:

```text
pi TUI + pi-bridge extension  <-- Unix socket JSONL -->  CLI / Neovim plugin
```

## Start a bridged pi agent

For quick testing from this repo:

```bash
pi -e ./pi-bridge/extension.ts --bridge
```

Or install/discover it globally later by copying or symlinking `extension.ts` into `~/.pi/agent/extensions/`.
When auto-discovered, the extension is dormant by default. Enable it per session with either:

```bash
pi --bridge
```

or from inside pi:

```text
/bridge start
```

Useful commands inside pi:

```text
/bridge status
/bridge stop
```

## Send a prompt from Neovim

This repo's Neovim config loads `lua/config/pi_bridge.lua`, which adds:

```text
:PiBridgeChat
:PiBridgeList
:PiBridgeStatus
:PiBridgeSend Summarize where we are
:PiBridgeFollowUp After that, list next steps
:PiBridgeAttachSelection
```

`:PiBridgeChat` opens a Markdown prompt-buffer split. Type a message at the `You>` prompt and press Enter to send it. Assistant text and tool activity stream back into the same split with Markdown syntax highlighting. Press `q` in normal mode to close it.

To attach code context to the chat split, visually select code and run:

```text
:PiBridgeAttachSelection
```

or use the default visual mapping:

```text
<leader>pa
```

Default mapping for opening chat:

```text
<leader>pc
```

You can also run `:PiBridgeSend` with no args to get an input prompt.

## Send a prompt from another terminal

```bash
./pi-bridge/bin/pi-bridge.js list
./pi-bridge/bin/pi-bridge.js send "Summarize where we are"
./pi-bridge/bin/pi-bridge.js send --follow-up "After that, list next steps"
```

If multiple bridged pi agents are running, `send` prompts you to select one. You can also target explicitly:

```bash
./pi-bridge/bin/pi-bridge.js send --agent 12345 "What session is this?"
```

## Protocol

Each running agent writes a registry file:

```text
~/.pi/agent/agent-bridge/agents/<pid>.json
```

The registry points to a Unix socket:

```text
~/.pi/agent/agent-bridge/sockets/pi-<pid>.sock
```

Clients send one JSON object per line:

```json
{"type":"status"}
{"type":"subscribe","history":true}
{"type":"prompt","message":"Hello from Neovim","deliverAs":"steer"}
{"type":"prompt","message":"Run after current work","deliverAs":"followUp"}
```

Responses/events are JSON objects followed by `\n`. Subscribed clients receive streaming events such as `assistant_delta`, `tool_start`, and `tool_end`.

## Notes

- This is local-machine only and currently Unix-socket based.
- The extension must be loaded when the pi process starts; it cannot attach to an already-running unbridged pi process.
- Default delivery is `steer`, so messages sent while pi is busy are queued as steering messages.
