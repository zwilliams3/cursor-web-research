#!/usr/bin/env bash
# Remove the 'playwright' MCP server from ~/.cursor/mcp.json and delete the
# web-research skill. Leaves the Playwright browser cache in place since it
# may be used by other tools.

set -euo pipefail

BLUE=$'\033[1;34m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; NC=$'\033[0m'
log()  { printf '%s[cursor-web-research]%s %s\n' "$BLUE" "$NC" "$*"; }
ok()   { printf '%s[cursor-web-research]%s %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%s[cursor-web-research]%s %s\n' "$YELLOW" "$NC" "$*"; }
die()  { printf '%s[cursor-web-research]%s %s\n' "$RED" "$NC" "$*" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || die "jq is required."

MCP_FILE="${HOME}/.cursor/mcp.json"
SKILL_DIR="${HOME}/.cursor/skills/web-research"

if [ -f "$MCP_FILE" ]; then
  BACKUP="${MCP_FILE}.bak.$(date +%s)"
  cp "$MCP_FILE" "$BACKUP"
  log "Backed up $MCP_FILE to $BACKUP."
  TMP=$(mktemp)
  jq 'if .mcpServers then .mcpServers |= del(.playwright) else . end' \
     "$MCP_FILE" > "$TMP" && mv "$TMP" "$MCP_FILE"
  ok "Removed 'playwright' entry from $MCP_FILE."
else
  warn "$MCP_FILE does not exist, skipping."
fi

if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  ok "Removed $SKILL_DIR."
else
  warn "$SKILL_DIR does not exist, skipping."
fi

cat <<EOF

${GREEN}Uninstalled.${NC} Reload Cursor to pick up the change.

Note: the Chromium download in ~/Library/Caches/ms-playwright was left in
place. To remove it too:

  rm -rf ~/Library/Caches/ms-playwright
EOF
