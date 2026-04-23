#!/usr/bin/env bash
# cursor-web-research installer.
#
# Gives Cursor a web-research superpower by:
#   1. Registering Microsoft's official Playwright MCP server in
#      ~/.cursor/mcp.json (merging, never clobbering).
#   2. Installing the Chromium browser Playwright drives.
#   3. Dropping global skills at ~/.cursor/skills/web-research and
#      ~/.cursor/skills/research (the /research entry for this repo).
#
# Idempotent: safe to re-run.

set -euo pipefail

BLUE=$'\033[1;34m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; NC=$'\033[0m'
log()  { printf '%s[cursor-web-research]%s %s\n' "$BLUE" "$NC" "$*"; }
ok()   { printf '%s[cursor-web-research]%s %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%s[cursor-web-research]%s %s\n' "$YELLOW" "$NC" "$*"; }
die()  { printf '%s[cursor-web-research]%s %s\n' "$RED" "$NC" "$*" >&2; exit 1; }

# --- 0. Preconditions ---------------------------------------------------------

command -v node >/dev/null 2>&1 || die "Node.js is required. Install from https://nodejs.org (>= 18) and re-run."
command -v npx  >/dev/null 2>&1 || die "npx is required (ships with Node). Re-install Node and re-run."
command -v jq   >/dev/null 2>&1 || die "jq is required. Install via Homebrew: 'brew install jq'."

NODE_MAJOR=$(node -v | sed 's/^v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
  die "Node >= 18 required; found $(node -v)."
fi

ok "Node $(node -v), npx $(npx -v), jq $(jq --version) detected."

# --- 1. Resolve paths ---------------------------------------------------------

CURSOR_DIR="${HOME}/.cursor"
MCP_FILE="${CURSOR_DIR}/mcp.json"
SKILLS_WEB_DIR="${CURSOR_DIR}/skills/web-research"
SKILLS_RESEARCH_DIR="${CURSOR_DIR}/skills/research"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_WEB_SRC="${SCRIPT_DIR}/skills/web-research/SKILL.md"
SKILL_RESEARCH_SRC="${SCRIPT_DIR}/skills/research/SKILL.md"

[ -f "$SKILL_WEB_SRC" ] || die "Cannot find $SKILL_WEB_SRC. Run install.sh from the repo root."
[ -f "$SKILL_RESEARCH_SRC" ] || die "Cannot find $SKILL_RESEARCH_SRC. Run install.sh from the repo root."

mkdir -p "$CURSOR_DIR" "$SKILLS_WEB_DIR" "$SKILLS_RESEARCH_DIR"

# --- 2. Install Chromium for Playwright --------------------------------------

log "Installing Chromium for Playwright (this may take ~30s on first run)..."
npx --yes playwright install chromium >/dev/null
ok "Chromium installed."

# --- 3. Merge mcp.json --------------------------------------------------------

# Headed (visible) browser is @playwright/mcp's default. Only pass "--headless"
# for headless—there is no --headless=false; that flag is rejected by the CLI.
PLAYWRIGHT_ENTRY='{"command":"npx","args":["@playwright/mcp@latest"]}'

if [ ! -f "$MCP_FILE" ]; then
  log "Creating $MCP_FILE."
  printf '{"mcpServers":{}}' > "$MCP_FILE"
fi

BACKUP="${MCP_FILE}.bak.$(date +%s)"
cp "$MCP_FILE" "$BACKUP"
log "Backed up existing config to $BACKUP."

TMP=$(mktemp)
if jq --argjson entry "$PLAYWRIGHT_ENTRY" \
      '.mcpServers = ((.mcpServers // {}) + {playwright: $entry})' \
      "$MCP_FILE" > "$TMP"; then
  mv "$TMP" "$MCP_FILE"
  ok "Registered 'playwright' server in $MCP_FILE."
else
  rm -f "$TMP"
  die "Failed to update $MCP_FILE. Your backup is at $BACKUP."
fi

# --- 4. Install the skills (cursor-web-research) ------------------------------

cp "$SKILL_WEB_SRC" "${SKILLS_WEB_DIR}/SKILL.md"
ok "Installed web-research skill at ${SKILLS_WEB_DIR}/SKILL.md."

cp "$SKILL_RESEARCH_SRC" "${SKILLS_RESEARCH_DIR}/SKILL.md"
ok "Installed /research skill at ${SKILLS_RESEARCH_DIR}/SKILL.md."

# --- 5. Next steps ------------------------------------------------------------

cat <<EOF

${GREEN}Done.${NC} Next steps:

  1. Quit and reopen Cursor (or reload the MCP config from Settings -> MCP).
  2. Open Cursor Settings -> MCP. You should see 'playwright' listed with a
     green status and around 20 tools (browser_navigate, browser_click, ...).
  3. In any chat, use /research or ask: "research the latest Playwright MCP release".
     It should open Chromium, read a couple of pages, and return a cited
     summary.

To uninstall later, run ./uninstall.sh from this repo.
EOF
