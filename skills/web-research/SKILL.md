---
name: web-research
description: >-
  Autonomously research the open web via the Playwright MCP server when the
  user wants fresh or verifiable information: "research", "look up",
  "find docs for", "compare", "what's the latest on", "/research", or browsing
  to specific URLs. Prefer primary sources; deliver a cited markdown summary.
  Pair with the sibling skill `research` (same workflow). If Playwright tools
  are unavailable, fall back to web search plus URL fetch and say so.
---

# Web research skill

**Repository:** [cursor-web-research](https://github.com/zwilliams3/cursor-web-research). **`/research`** maps to the sibling [`skills/research/SKILL.md`](https://github.com/zwilliams3/cursor-web-research/blob/main/skills/research/SKILL.md) — same workflow, project-branded entry point.

**Intent:** Turn Playwright MCP into a **repeatable research behavior**: plan → open real pages → extract facts with URLs → summarize. Success is **not** “called many tools”; success is a **short, cited answer** backed by **at least one page opened beyond the search-results screen**.

---

## When to activate

Use this skill when the user clearly wants **external, time-sensitive, or verifiable** information:

- Wording like: research, look up, find docs, compare, what’s new/latest, browse to, open this URL and explain.
- Factual questions likely **newer than training data** or **owned by a specific site** (release notes, pricing, API docs).

**Do not use** for:

- Anything answerable from **this repo**, **this chat**, or **stable textbook facts** without a source requirement.
- **User explicitly opts out** of the browser (“just answer from memory”, “no MCP”) — honor that and skip Playwright.

---

## Success criteria (behavior)

Before you finish, check:

1. **At least one substantive page** was opened and read (not only search-result snippets).
2. **Every non-obvious claim** has an inline link to the URL it came from (or is labeled uncited).
3. **Caveats** include uncertainty, skipped paywalls, CAPTCHA, or conflicting sources.

If Playwright was unavailable and you used fallback search/fetch, say so under **Caveats**.

---

## Pre-flight

1. **Tools:** If the Playwright MCP tools (names usually prefixed with `browser_`, e.g. `browser_navigate`, `browser_snapshot`) **do not appear** in this session, **do not pretend** you browsed. Either:
   - Tell the user to enable **Settings → MCP → playwright**, or  
   - Use **fallback** (below), then label the answer accordingly.
2. **Exact tool names** can vary slightly by `@playwright/mcp` version — use whatever **browser automation tools this client actually exposes**, mapped to the same jobs: navigate, snapshot, click, tabs, wait, close.

### Fallback when Playwright is missing

Use **web search** plus **fetch/read public URLs** your environment provides. **Limitations:** no clicking past paywalls, weak on heavy JS sites — state that in **Caveats**. Still cite URLs for every extracted claim.

---

## Standard research loop

1. **Plan (brief).** 1–3 queries; prefer **direct URLs** when the user names a product or domain (e.g. `playwright.dev/docs/...`) instead of always starting from a search engine.
2. **Search (if needed).** Navigate to a SERP via encoded URL (e.g. DuckDuckGo or Google `?q=`). Prefer URL bar over typing into the box unless that fails.
3. **Snapshot.** Use **accessibility snapshots** for structure and refs; avoid pasting huge HTML into chat.
4. **Pick sources.** Open up to **3** high-signal links in **separate tabs**; skip obvious SEO farms unless asked.
5. **Read each tab.** One snapshot per navigation is usually enough; extract quotes, version numbers, dates, flags — **always pair with the page URL**.
6. **Refine at most once.** If still unclear after first pass + reads, one narrowed search or ask the user — don’t spiral.
7. **Cleanup.** Close tabs when done; close browser if the session is clearly finished.
8. **Summarize** using **Output format** below.

### Consent and interstitials

If a **cookie / consent** banner blocks content and you can dismiss it with a **single, obviously benign** control (e.g. “Accept”), you may click it. **No** consent flows that ask for accounts, payments, or ambiguous “subscribe”. If stuck, note it in **Caveats** and try another source.

---

## Budgets and stop rules

Unless the user raises limits:

| Limit | Value |
| --- | --- |
| Tabs open at once | **≤ 5** |
| Total navigations | **≤ 15** |
| Wall-clock | **~2 minutes** — then stop, partial summary + gaps |
| Search refinements after first pass | **≤ 1** |

---

## Safety rails

Hard stops — ask the user rather than guessing:

1. **No sign-in**, banking, email, or personal dashboards.
2. **No non-search forms** (signup, checkout, contact, “confirm purchase”).
3. **No downloads** — paste URL only.
4. **No destructive actions** (delete, unsubscribe, etc.).
5. **Paywalls / forced login** — skip source; say so.
6. **CAPTCHA** — stop automation; partial summary + ask user.
7. **Light touch on sites:** don’t hammer one origin (stay roughly within ~10 navigations per origin per task unless the user narrows to one docs site).
8. **No arbitrary page `eval`** unless the user explicitly requests it.

---

## Output format

End with:

```markdown
## Research: <one-line restatement>

**Short answer:** <2–3 sentences>

**Key findings**
- <fact> ([source](url))
- <fact> ([source](url))

**Sources consulted**
1. [Title](url) — why it mattered
2. [Title](url) — why it mattered

**Caveats**
- <paywalls, CAPTCHA, MCP unavailable / fallback used, conflicts between sources, uncertainty>
```

Never invent URLs. Conflicting primaries → summarize both and cite both.

---

## Anti-patterns (don’t)

- **SERP-only answers** — always open ≥1 real destination page.
- **Snapshot loops** — re-snapshotting the same DOM without a new navigation rarely helps.
- **Wall-of-text dumps** — extract; don’t paste whole pages.
- **Zombie tabs** — don’t leave many tabs open after you’re done.
- **Config churn** — don’t change MCP headless/headed flags mid-task; fix config outside the chat. (`--headless` exists; `--headless=false` does **not**.)

---

## Quick examples

**Bun vs Node for TS:** Search → Bun docs + Node release/docs in two tabs → snapshots → cited comparison → close.

**Playwright MCP trace:** Go straight to `github.com/microsoft/playwright-mcp` and `playwright.dev/docs/getting-started-mcp` → snapshot relevant sections → cite flags and doc anchors.
