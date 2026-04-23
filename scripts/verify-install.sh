#!/usr/bin/env bash
# Non-interactive checks after install. Does not prove Cursor has loaded the MCP
# (see README: Settings -> MCP) but proves files and toolchains look correct.
set -euo pipefail
ERR=0
warn() { echo "WARN: $*" >&2; }
die()  { echo "FAIL: $*" >&2; ERR=1; }
pass() { echo "OK:   $*"; }

CURSOR_MCP="${HOME}/.cursor/mcp.json"
SKILL_WEB="${HOME}/.cursor/skills/web-research/SKILL.md"
SKILL_RESEARCH="${HOME}/.cursor/skills/research/SKILL.md"

command -v node >/dev/null || { die "Node.js not found"; exit 1; }
NODE_MAJOR=$(node -v | sed 's/^v//' | cut -d. -f1)
[ "$NODE_MAJOR" -ge 18 ] && pass "Node $(node -v)" || die "Need Node >= 18"

command -v jq >/dev/null && pass "jq present" || die "jq not found ( brew install jq )"

[ -f "$CURSOR_MCP" ] && pass "~/.cursor/mcp.json exists" || die "Missing $CURSOR_MCP"
jq -e '(.mcpServers.playwright.args // [] | map(.) | join(" ")) | test("@playwright/mcp")' "$CURSOR_MCP" >/dev/null 2>&1 && \
  pass "mcp.json contains @playwright/mcp" || die "mcp.json missing playwright / @playwright/mcp in args"

[ -f "$SKILL_WEB" ] && pass "Global skill: ~/.cursor/skills/web-research/SKILL.md" || \
  die "Missing web-research skill: run install.sh or copy from repo"
[ -f "$SKILL_RESEARCH" ] && pass "Global skill: ~/.cursor/skills/research/SKILL.md (/research)" || \
  die "Missing research skill: run install.sh or copy from repo"

if npx --yes @playwright/mcp@latest --help 2>&1 | grep -qE 'version|headless|Options'; then
  pass "npx can run @playwright/mcp@latest --help (CLI available)"
else
  warn "Could not run @playwright/mcp@latest --help; check network / npx cache"
  ERR=1
fi

if [ "$ERR" -eq 0 ]; then
  echo ""
  echo "All script checks passed. In Cursor, open **Settings -> MCP** and confirm"
  echo "the **playwright** server is green and lists ~20 tools."
else
  exit 1
fi
