# AGENTS.md
> AI Agent Configuration — TradeZella_STB
> Read by: Claude Code, Cursor, GitHub Copilot, and other AI coding assistants.
> See `CLAUDE.md` for Claude Code–specific rules.

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

## Project Overview

**TradeZella_STB** is the data pipeline that converts TradeZella trade journal CSV exports into SmartTradingBlueprint (STB) Google Sheets format. Feeds the Fortuna trading review workflow.

**Visibility:** PRIVATE
**Primary builder:** Auggie (Augment CLI)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Python 3.x |
| Google Sheets API | `gspread` |
| Auth | Google service account (JSON key — gitignored) |
| Input | TradeZella CSV exports |
| Output | STB-format Google Sheets |
| Package manager | pip |

---

## Common Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run pipeline (primary output: Google Sheets)
python tradezella_to_stb.py --sheets

# Run with local CSV output
python tradezella_to_stb.py --csv

# Test with sample data
python tradezella_to_stb.py --dry-run
```

---

## Coding Standards

- All credentials via service account JSON — gitignored, never committed
- Trade data (account numbers, P&L) is private — never logged or exposed
- Type hints on all public functions
- `ruff` for linting

---

## Agent Boundaries

**Do:**
- Process CSV data and transform it to the STB format spec
- Output clean, formatted data to Google Sheets or local CSV
- Follow the column mapping spec exactly (defined in `tradezella_to_stb.py`)

**Don't:**
- Commit `service_account.json` or any real credential
- Log trade account numbers, broker credentials, or prop firm access tokens
- Modify the Google Sheet structure without confirming with Christopher

---

## Security Rules

- `service_account.json` is always gitignored — warn and stop if staged
- Trade account data is private — never appears in logs, print statements, or committed files
- Before pip packages: verify provenance, check for suspicious install hooks

---

## Override System

Create `AGENTS.override.md` for temporary task-specific rules. Delete when done. Template: `~/code/my-template/AGENTS.override.md`

---

## Canonical References

- `CLAUDE.md` — Agent roles, scope boundaries, and session rules
- `AGENTS.md` (this file) — Universal AI agent config
- `specs/tradezella-automater.spec.md` (in trading-assistant) — full pipeline spec

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
