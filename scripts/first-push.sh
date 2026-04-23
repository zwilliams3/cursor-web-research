#!/usr/bin/env bash
# Create the GitHub repo and push, or push to an existing origin.
# Requires: `brew install gh` and `gh auth login`.
# If origin is wrong (404 on push), run: git remote remove origin
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v gh &>/dev/null; then
  echo "Install GitHub CLI: brew install gh" >&2
  exit 1
fi
if ! gh auth status &>/dev/null; then
  echo "Run: gh auth login" >&2
  exit 1
fi

if git remote get-url origin &>/dev/null; then
  echo "Pushing to: $(git remote get-url origin)"
  git push -u origin main
  echo "Done. Set README curl URL to: $(gh api user -q .login)/cursor-web-research"
  exit 0
fi

gh repo create cursor-web-research --public --source="$REPO_ROOT" --remote=origin --push
echo "Pushed. Set README curl URL to: $(gh api user -q .login)/cursor-web-research"
