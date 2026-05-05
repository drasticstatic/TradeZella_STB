# CLAUDE.md — Persistent Instructions for TradeZella_STB
### TradeZella trade journal data pipeline — STB / SmartTradingBlueprint integration

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
