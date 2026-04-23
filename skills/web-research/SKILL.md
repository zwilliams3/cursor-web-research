---
name: web-research
description: >-
  Autonomously research a topic on the open web by driving a real browser via
  the Playwright MCP server. Use when the user asks to "research", "look up",
  "find docs for", "compare", "what's the latest on", "browse to", or
  otherwise wants fresh information that is not in the codebase or training
  data. The skill opens tabs, clicks through results, reads pages, and returns
  a cited markdown summary.
---

# Web research skill

Turns the browser-automation tools from the `playwright` MCP server into a
reliable, self-driving research loop. Without this skill the tools exist but
the agent has to be nudged click-by-click; with it, "research X" becomes a
single-shot behavior.

## When to activate

Activate automatically when the user's message contains intent like:

- "research ...", "look up ...", "find docs for ...", "find information on ..."
- "what's the latest on ...", "what's new in ...", "compare X vs Y"
- "browse to ...", "open ... and tell me ..."
- Any factual question where the answer is likely newer than your training
  data or obviously lives on a specific website.

Do **not** activate for questions you can answer from the current codebase, the
conversation, or well-known stable facts.

## Required tools

This skill assumes the `playwright` MCP server is registered (see
`~/.cursor/mcp.json`). The relevant tools are:

- `browser_navigate` — load a URL in the active tab
- `browser_snapshot` — get an accessibility-tree snapshot of the page (prefer
  this over raw HTML; it is smaller and already labelled)
- `browser_click` — click an element from the snapshot
- `browser_type` — type into an input
- `browser_press_key` — press Enter, etc.
- `browser_tab_new` / `browser_tab_list` / `browser_tab_select` / `browser_tab_close`
- `browser_wait_for` — wait for text or a selector to appear
- `browser_close` — close the browser when done

If any of these tools are missing, stop and tell the user the Playwright MCP
server is not connected; point them at Cursor Settings -> MCP.

## Standard research loop

1. **Plan (silently).** Decide the 1-3 queries you actually need. Prefer
   primary sources (official docs, GitHub READMEs, RFCs, vendor blogs) over
   aggregators.
2. **Search.** `browser_navigate` to a search engine results page directly
   via URL, for example
   `https://duckduckgo.com/?q=<url-encoded-query>` or
   `https://www.google.com/search?q=<url-encoded-query>`. Do not try to type
   into the search box unless the direct-URL form fails.
3. **Scan results.** `browser_snapshot` and pick up to 3 promising links.
   Ignore obvious SEO spam, pinterest, quora-style pages, and anything that
   looks AI-generated unless the user asked for them specifically.
4. **Open each link in its own tab.** Use `browser_tab_new` with the URL so
   you can compare sources in parallel.
5. **Read.** On each tab, `browser_snapshot` and extract the concrete facts,
   version numbers, code snippets, or quotes you need. Capture the page URL
   alongside every fact so you can cite it later.
6. **Follow up only if needed.** If the answer is still unclear after reading
   the top results, do at most one refined search. Do not spiral.
7. **Close tabs.** `browser_tab_close` each tab when done, then
   `browser_close` the browser if the user is unlikely to want another
   immediate research task. Leaving it open is fine during an active session.
8. **Summarize.** Return a concise markdown summary (see "Output format").

## Budgets and stop rules

Honor these limits unless the user explicitly raises them:

- **Tabs per research task: 5 maximum.** If you need more, stop and ask.
- **Navigations per research task: 15 maximum.**
- **Wall-clock: aim for under 2 minutes.** If you are still navigating after
  roughly that long, stop, summarize what you have, and note what is missing.
- **One refinement pass.** If the first search and three reads do not answer
  the question, surface that to the user instead of burning more tabs.

## Safety rails

Hard rules. Violating any of these should make you stop and ask the user.

1. **Never sign in.** If a page requires login, close the tab and pick a
   different source.
2. **Never submit forms** other than a search box. No contact forms, no
   signup flows, no checkout flows.
3. **Never download files.** If a result is only available as a PDF or ZIP
   download, note the URL in the summary and let the user fetch it.
4. **Never click anything destructive** — "delete", "unsubscribe",
   "purchase", "confirm", etc.
5. **Paywalls and auth walls: stop and ask.** Do not try to bypass them.
6. **Avoid user-identifying sites.** Do not navigate to the user's email,
   banking, social, or cloud-console tabs even if a link points there.
7. **Respect `robots.txt` spirit.** Read pages, do not scrape entire sites.
   No more than roughly 10 navigations to a single origin in one task.
8. **No JavaScript eval on arbitrary pages** unless the user explicitly asks.
9. **Stop on CAPTCHA.** Summarize partial findings and ask the user.

## Output format

End every research task with a summary like this:

```markdown
## Research: <one-line restatement of the question>

**Short answer:** <2-3 sentences.>

**Key findings**
- <fact> ([source](url))
- <fact> ([source](url))

**Sources consulted**
1. [Page title](url) — <one-line why it mattered>
2. [Page title](url) — <one-line why it mattered>

**Caveats**
- <anything you could not verify, any paywalled source you skipped, any
  conflicting info between sources>
```

Every non-trivial claim must carry an inline source link. If a fact has no
citable URL, say so explicitly instead of inventing one.

## Failure modes to avoid

- Do **not** return a summary based only on the search-results snippets; open
  at least one real page.
- Do **not** loop on `browser_snapshot` of the same page — one snapshot per
  visit is usually enough.
- Do **not** copy giant page dumps into the chat; extract the relevant parts.
- Do **not** leave the browser with 10+ open tabs when the task is done.
- Do **not** escalate headless/headful or other MCP flags mid-task; if the
  server is misconfigured, stop and tell the user.

## Quick examples

User: *"Research the current state of Bun 2.0 vs Node 22 for running
TypeScript directly."*

Good behavior: navigate to a search for "Bun 2.0 TypeScript support", open
the Bun docs and the Node.js release notes in separate tabs, read both,
close them, return a summary with both URLs cited.

User: *"Find me the official Playwright MCP docs and tell me how to enable
trace recording."*

Good behavior: navigate to `https://github.com/microsoft/playwright-mcp` and
`https://playwright.dev/docs/getting-started-mcp`, snapshot the relevant
sections, cite the exact flag name and docs URL in the summary.
