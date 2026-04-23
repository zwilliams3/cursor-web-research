#!/usr/bin/env bash
# Proves Playwright can drive Chromium and load a public page (no Cursor required).
# Uses: npx playwright (same browser cache as @playwright/mcp if versions align).
# Run from repo root: ./scripts/smoke-browser.sh
set -euo pipefail
OUT="$(mktemp /tmp/cursor-web-research-pw-XXXXXX.png)"
trap 'rm -f "$OUT"' EXIT
npx --yes playwright screenshot "https://example.com" "$OUT"
if [ ! -s "$OUT" ]; then
  echo "smoke-browser: failed (empty screenshot)" >&2
  exit 1
fi
echo "smoke-browser-ok: Playwright opened Chromium and captured example.com"
