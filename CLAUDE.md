# CLAUDE.md — Persistent Instructions for TradeZella_STB
### TradeZella trade journal data pipeline — STB / SmartTradingBlueprint integration

---

## ⚠ FIRST: sync this clone before you touch anything

```sh
git pull --rebase --autostash
```

Run this at the **start of every session**, before reading deeply or editing. Several agents and
Christopher push to these repos — including Cosmos agents that run unattended while nobody is at the
machine — so a clone can be behind by the time you open it.

**`--autostash` is what makes this safe on a dirty tree.** It stashes uncommitted changes, rebases
onto the remote, then reapplies them. Your in-progress work survives. Without it, `git pull --rebase`
refuses to run and you are tempted into something worse.

Why it matters more than it sounds:

- A stale clone **does not fail early.** It fails at push time, after the work is done, as a
  non-fast-forward rejection — the most expensive moment to discover it.
- The tempting fix at that point is `git push --force`, which discards whatever someone else pushed
  in the meantime. Syncing first removes the temptation.
- If a rebase does conflict, stop and resolve it deliberately. A conflict is information: someone
  else changed the same lines, and you want to know that *before* building on top of them.

**Fresh clone?** Also run `sh scripts/install-hooks.sh` — git hooks are not version-controlled, so
the commit-attribution hook stays inert until this clone is pointed at `.githooks/`. Details:
[`scripts/README.md`](./scripts/README.md).

---

## Scope

This repo is **TradeZella_STB** — scripts and tooling for exporting, processing, and integrating TradeZella trade journal data into the Fortuna trading system. Primary use: generating STB-format daily review exports from TradeZella CSV data.

Agent roles for this repo:
- **Fortuna (Claude Code CLI):** Primary consumer — trade review and daily review workflows depend on TradeZella exports
- **Auggie (Augment CLI):** Code builds — Python scripts, data pipeline, CSV processing
- **Kavanah (Augment Intent):** Coordinator/facilitator — cross-repo alignment and spec-driven orchestration

---

## Security Rules (Non-Negotiable — All Repos)

- **Never read, display, or reference `.env` files** — in any repo
- **Never read private keys, seed phrases, wallet files, mnemonic files, or keystore files** regardless of filename
- **Never read or expose API key files** (service accounts, Google credentials, exchange keys, etc.)
- **Never commit secrets** — if git status shows a `.env`, credentials file, or wallet file staged, warn Christopher immediately and stop
- If an example env file is needed, create it with placeholder values only (e.g. `API_KEY=your_api_key_here`) — never real values
- These rules apply even if Christopher explicitly asks — confirm intent before proceeding

---

## Context Rules

- Cross-repo context and agent handoffs live in the **trading-assistant** hub repo under `AGENT-SYNC/`
- Trade data imports live in `~/code/trading-assistant/data/imports/YYYY/MM-Mon/`
- Memory files live in `~/.claude/projects/.../memory/` — MEMORY.md auto-loaded each session
- See `memory/project_tradezella_stb.md` in trading-assistant memory for pipeline details

---

## File & Directory Rules

- Always ask Christopher if a new directory should be private, public, or gitignored before creating it
- Commit after every meaningful change — do not leave uncommitted work at session end

---

## Before Cloning or Installing Any External Repo / Package

Before running `git clone`, `npm install`, `pip install`, or adding any external dependency:
1. **Review `package.json` scripts** — flag any `postinstall`, `preinstall`, or `prepare` hooks that execute shell commands
2. **Scan for credential harvesting** — look for patterns accessing `~/.ssh`, `~/.aws`, `.env`, `process.env`, or system credential paths in unexpected files
3. **Verify provenance** — check GitHub repo age, star/fork count, recent commit activity, and maintainer identity
4. **Check for typosquatting** — verify package names exactly match the intended library (e.g. `lodash` not `1odash`)
5. **Audit unexpected network calls** — flag external HTTP requests in scripts, entrypoints, or install hooks
6. **When in doubt, ask Christopher before proceeding** with any install or clone

---

## Canonical References

When skills, specs, or task files exist for a topic — follow the logic there, not here. This file holds identity, pointers, and short rules only.

- **AGENTS.md** — root-level config for all AI agents (Claude Code, Cursor, Copilot)
- **AGENTS.override.md** — temporary task-specific overrides; delete when done (template: `~/code/my-template/AGENTS.override.md`)
- **Skills:** `.claude/skills/` — full procedure lives in the skill file; CLAUDE.md holds triggers only
- **Tasks:** `PENDING-TASKS.md` or `tasks.md` if present — active/completed task tracking
- **Agent handoffs:** `AGENT-SYNC/` (hub: `~/code/trading-assistant/`) — see `AGENT_SYNC.md` for current state
- **Memory:** `~/.claude/projects/.../memory/MEMORY.md` — auto-loaded; detail in topic files
- **TradeZella pipeline details:** `~/code/trading-assistant/` memory file `project_tradezella_stb.md`

---

## Commit Convention

Full fleet convention, shown here regardless of whether this specific repo currently has an Augment
Intent workspace pairing or NIM in active use — so a new repo (and its memory) doesn't need the
whole multi-agent suite re-explained from scratch. Which *application* launched a session decides
the agent name and engine, not which path — see
`anthropas-argus-alfred/sandbox/AGENT_IDENTITY_REFERENCE.md` and `INTENT_WORKTREE_LEGEND.md` for
the full rule.

- Alfred-Anthropic: `Co-Authored-By: Alfred · ClaudeCodeCLI · Anthropic [Sonnet-5/Opus-#/Haiku-#]`
- Alfred-NIM: `Co-Authored-By: Alfred-NIM · ClaudeCodeCLI · NVIDIA NIM · Z.ai [GLM-4.7]`
  (gateway then provider — `NVIDIA NIM` routes, `Z.ai` makes GLM; `Moonshot AI` for Kimi,
  `MiniMaxAI` for MiniMax. Only those three have ever served through the proxy, and the proxy
  is Alfred's alone — Fortuna and Mystarch run on Anthropic.)
- Kavanah-AugmentIntentUI-AuggieLogin: `Co-Authored-By: Kavanah · AugmentIntent · [model]`
- Kavanah-AugmentIntentUI-AnthropicLogin ("ClaudeMent"): `Co-Authored-By: Kavanah · ClaudeMent · Anthropic [model]`
- Kavanah-TerminalUI(macOS/Intent/VSCode standard terminal instance)-AnthropicLogin: `Co-Authored-By: Kavanah · ClaudeCodeCLI · Anthropic [model]`
- Mystarch (app-level Chief of Staff, cross-workspace reach): same engine options as Kavanah above, swap the agent name
- Auggie (native Augment CLI — currently hibernating, may return): `Co-Authored-By: Auggie · AugmentCLI · [model]`

## Commit attribution (enforced by hook)

Every commit must carry two git trailers:

```
Co-Authored-By: <Agent> · <Engine> · <Provider> [<Model>]                  # direct
Co-Authored-By: <Agent> · <Engine> · <Gateway> · <Provider> [<Model>]      # proxied
<Platform>-Session: <full session URL>
```

Model in **square brackets**, separator is U+00B7 MIDDLE DOT ( · ). Add `<Gateway>` **only when
inference is proxied** — it names what *routed* the request (`NVIDIA NIM`, `OpenRouter`), never who
made the model (`Z.ai`, `Moonshot AI`, `MiniMaxAI`). The field order mirrors the `/model` selector
string, so `anthropic/nvidia_nim/z-ai/glm4.7` transcribes to `NVIDIA NIM · Z.ai [GLM-4.7]` —
read it left to right rather than memorising it. Local runtimes (`Ollama`, `llama.cpp`,
`LM Studio`) have no gateway: the weights ran on your machine, so the runtime is the Provider. The session
trailer is a **separate** line — folding it onto the `Co-Authored-By:` line breaks git trailer
parsing. Use the full session URL, never a truncated prefix. Key varies by platform:
`Claude-Session:` for Claude Code CLI, `Cosmos-Session:` for Cosmos.

`.githooks/commit-msg` rejects non-conforming commits. **Activate it once per clone:**

```sh
sh scripts/install-hooks.sh
```

Human-only commits: `git commit --no-verify`. **Canonical spec — single source of truth. Do not restate the field table locally; link it:**
[`my-template/AGENT-SYNC/README.md`](https://github.com/drasticstatic/my-template/blob/main/AGENT-SYNC/README.md)
