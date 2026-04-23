---
name: research
description: >-
  The /research entry point for the cursor-web-research project: autonomous web
  research with Playwright MCP. Use when the user invokes /research or asks
  to research, look up, or browse for fresh information using the stack from
  https://github.com/zwilliams3/cursor-web-research. Treated as a first-class
  alias to the same workflow as the web-research skill from that repository.
---

# /research (cursor-web-research)

This skill is **part of the [cursor-web-research](https://github.com/zwilliams3/cursor-web-research)** project. The installer in that repository copies it to `~/.cursor/skills/research/SKILL.md` and registers Playwright MCP.

## Relationship to this project

| Item | Link |
| --- | --- |
| Repository | [zwilliams3/cursor-web-research](https://github.com/zwilliams3/cursor-web-research) |
| One-line install | `curl -fsSL https://raw.githubusercontent.com/zwilliams3/cursor-web-research/main/install.sh \| bash` |
| Full research rules (sibling in the repo) | [skills/web-research/SKILL.md](https://github.com/zwilliams3/cursor-web-research/blob/main/skills/web-research/SKILL.md) — after install also at `~/.cursor/skills/web-research/SKILL.md` |

`research` and `web-research` describe the **same** Playwright-based workflow. The **`/research` slash command** maps to this skill by name. When either skill applies, follow the full procedure, budgets, safety rails, and output format in **web-research** (do not skip steps because this file is short).

## When the user types /research

1. **Topic** is everything after `/research` (or the user’s follow-up in the same thread). If empty, ask what they want researched.
2. **Execute** the standard research loop using the `playwright` MCP tools, exactly as defined in the **web-research** skill: navigate → snapshot → new tabs for top results → read → close → **cited markdown summary**.
3. If Playwright tools are missing, tell the user to run the [install](https://github.com/zwilliams3/cursor-web-research#quickstart) and restart Cursor, then check **Settings → MCP**.

## Do not

- Answer from memory alone for “latest / current / 2025+” type questions; use the browser unless the user explicitly says not to.
- Conflate this with a different `research` feature outside this repository—this one is always tied to **cursor-web-research** + Playwright MCP.
