#!/bin/bash
# ═════════════════════════════════════════════════════════════════════════════
# TradeZella → STB  |  macOS Automator Drop Handler
# ─────────────────────────────────────────────────────────────────────────────
# HOW TO SET UP IN AUTOMATOR (one-time, ~3 minutes):
#
#   1. Open Automator  (Spotlight → "Automator")
#   2. Choose "Application" as the document type
#   3. In the search bar type "Run Shell Script" → drag it into the workflow
#   4. Set "Pass input:" dropdown → "as arguments"
#   5. Delete any default code, paste the ENTIRE contents of this file
#   6. File → Save → name it "TradeZella to STB" → save to Desktop
#
# HOW TO USE EVERY TIME:
#   - Export trades from TradeZella as .csv
#   - Drag the .csv file onto "TradeZella to STB" on your Desktop
#   - Done — output appears in same folder as the CSV (or goes to Google Sheets)
# ═════════════════════════════════════════════════════════════════════════════

# ── Config: update these paths if you move the folder ─────────────────────────
SCRIPT_DIR="$HOME/TradeZella_STB"
SCRIPT_PATH="$SCRIPT_DIR/tradezella_to_stb.py"
# ──────────────────────────────────────────────────────────────────────────────

# Use the virtual environment Python if it exists (preferred — avoids
# Homebrew's externally-managed-environment restriction).
# Falls back to system python3 if venv hasn't been created yet.
VENV_PYTHON="$SCRIPT_DIR/venv/bin/python3"

if [ -x "$VENV_PYTHON" ]; then
    PYTHON="$VENV_PYTHON"
else
    # venv not found — try to locate system Python and create it
    for candidate in \
        "$(which python3 2>/dev/null)" \
        "/opt/homebrew/bin/python3" \
        "/usr/local/bin/python3" \
        "$HOME/.pyenv/shims/python3"
    do
        if [ -x "$candidate" ]; then
            SYS_PYTHON="$candidate"
            break
        fi
    done

    if [ -z "$SYS_PYTHON" ]; then
        osascript -e 'display alert "Python Not Found" message "Python 3 is required.\n\nInstall from python.org or run:\n  brew install python3" as critical'
        exit 1
    fi

    # Create venv and install packages automatically on first run
    osascript -e 'display notification "Setting up Python environment... (~30 sec, one time only)" with title "TradeZella → STB"'
    "$SYS_PYTHON" -m venv "$SCRIPT_DIR/venv"
    "$SCRIPT_DIR/venv/bin/pip" install pandas openpyxl gspread google-auth --quiet
    PYTHON="$VENV_PYTHON"
fi

# Validate script path
if [ ! -f "$SCRIPT_PATH" ]; then
    osascript -e "display alert \"Script Not Found\" message \"Could not find tradezella_to_stb.py at:\n$SCRIPT_PATH\n\nMake sure your files are in:\n$SCRIPT_DIR\" as critical"
    exit 1
fi

# Process each dropped file
SUCCESS_COUNT=0
FAIL_COUNT=0

for CSV_FILE in "$@"; do

    # Only process .csv files
    if [[ "${CSV_FILE##*.}" != "csv" ]]; then
        osascript -e "display notification \"Skipped — not a .csv file: $(basename "$CSV_FILE")\" with title \"TradeZella → STB\""
        continue
    fi

    # Run the merge script (auto-mode: Sheets if configured, xlsx otherwise)
    OUTPUT=$("$PYTHON" "$SCRIPT_PATH" "$CSV_FILE" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

        # Check if output was a file (xlsx mode) and open it
        OUTPUT_FILE=$(echo "$OUTPUT" | grep "→" | grep -o '/.*\.xlsx' | head -1)
        if [ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ]; then
            open "$OUTPUT_FILE"
            osascript -e "display notification \"✅ $(basename "$CSV_FILE") → $(basename "$OUTPUT_FILE")\" with title \"TradeZella → STB\" subtitle \"File opened\""
        else
            # Google Sheets mode — no file to open
            osascript -e "display notification \"✅ $(basename "$CSV_FILE") uploaded to Google Sheets\" with title \"TradeZella → STB\""
        fi
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        # Show error details in an alert
        osascript -e "display alert \"Conversion Failed\" message \"Error processing: $(basename "$CSV_FILE")\n\n$OUTPUT\" as critical"
    fi

done

# Final summary if multiple files were dropped
if [ $((SUCCESS_COUNT + FAIL_COUNT)) -gt 1 ]; then
    osascript -e "display notification \"${SUCCESS_COUNT} succeeded, ${FAIL_COUNT} failed\" with title \"TradeZella → STB\" subtitle \"Batch complete\""
fi
