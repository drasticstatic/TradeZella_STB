# AGENTS.md
> AI Agent Configuration — TradeZella_STB
> Read by: Claude Code, Cursor, GitHub Copilot, and other AI coding assistants.
> See `CLAUDE.md` for Claude Code–specific rules.

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
Co-Authored-By: <Agent> · <Engine> · <Provider> [<Model>]
<Platform>-Session: <full session URL>
```

Four fields, model in **square brackets**, separator is U+00B7 MIDDLE DOT ( · ). The session
trailer is a **separate** line — folding it onto the `Co-Authored-By:` line breaks git trailer
parsing. Use the full session URL, never a truncated prefix. Key varies by platform:
`Claude-Session:` for Claude Code CLI, `Cosmos-Session:` for Cosmos.

`.githooks/commit-msg` rejects non-conforming commits. **Activate it once per clone:**

```sh
sh scripts/install-hooks.sh
```

Human-only commits: `git commit --no-verify`. Canonical convention and rationale:
[`my-template/AGENT-SYNC/README.md`](https://github.com/drasticstatic/my-template/blob/main/AGENT-SYNC/README.md)
