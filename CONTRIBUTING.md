# Contributing to cursor-web-research

Thanks for helping improve this small installer and skill.

## What belongs here

- `install.sh` / `uninstall.sh` should stay **idempotent** and safe to re-run.
- The skill in `skills/web-research/SKILL.md` is the product: keep activation triggers, budgets, safety rails, and output format in sync with how [`@playwright/mcp`](https://github.com/microsoft/playwright-mcp) actually works (read their changelog when you change behavior).
- Do not pin secrets or machine-specific paths in the repo.

## How to test locally

1. From the repo root, run `./install.sh` in a throwaway `HOME` if you want a clean test:

   ```bash
   FAKE_HOME=$(mktemp -d)
   HOME="$FAKE_HOME" bash ./install.sh
   cat "$FAKE_HOME/.cursor/mcp.json"
   ls "$FAKE_HOME/.cursor/skills/web-research/"
   ls "$FAKE_HOME/.cursor/skills/research/"
   rm -rf "$FAKE_HOME"
   ```

2. On your own Mac, re-run `./install.sh` and confirm `~/.cursor/mcp.json` still merges correctly and your backup is created.

3. From the repo: `./scripts/verify-install.sh` and optionally `./scripts/smoke-browser.sh`.

4. Restart Cursor and verify **Settings → MCP** shows `playwright` healthy, then run a one-line "research X" in chat.

5. Uninstall: `./uninstall.sh` and confirm the `playwright` key is removed from `mcp.json`.

## Pull requests

- One logical change per PR.
- Note in the PR if you changed the skill (agent-facing behavior) vs. only scripts or docs.
- If you add new CLI flags for Playwright MCP, link to the official docs and update the **Headless vs. headed** section in the README.

## License

By contributing, you agree your contributions are licensed under the same [MIT](LICENSE) license as the project.
