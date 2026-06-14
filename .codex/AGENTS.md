<!-- oracle -->
## Oracle second-opinion tool

The `oracle.consult` MCP tool sends a prompt from Codex to an external ChatGPT session. Oracle is not running inside Codex and cannot see Codex's MCP tools, terminal, workspace, local files, or conversation unless Codex explicitly includes that context in the prompt and `files`. Oracle still has access to normal ChatGPT tools such as web search.

Use Oracle as a regular token-saving thinking partner and second opinion, not as an autonomous agent. Codex remains responsible for local investigation, implementation, testing, and final judgment.

Consult Oracle regularly during substantial work:

* Before starting a non-trivial task, design, refactor, debugging session, migration, or risky change, ask Oracle to sanity-check the direction and suggest an approach.
* While working, ask Oracle when stuck, when local investigation is inconclusive, when tradeoffs are unclear, or when a fresh perspective may save time.
* Before finishing, ask Oracle to review Codex's own work: the proposed solution or patch, risk areas, tests, and anything Codex may have missed.

Oracle is optional for trivial mechanical edits, obvious one-line fixes, formatting-only changes, or tasks where sending context would cost more than solving locally.

Good Oracle prompts are compact and specific. Include:

* repo/task context
* relevant constraints and goals
* what Codex already observed or tried
* the current hypothesis, proposed plan, or patch
* the exact question Oracle should answer
* only relevant files, snippets, diffs, logs, or error output

Do not ask Oracle to act on local state directly. Ask for a solution, critique, direction, checklist, or explanation based only on the context provided.

Good uses:

* choosing an implementation plan before coding
* designing or comparing architecture options
* researching a topic online
* debugging after initial local investigation
* reviewing a proposed patch or risky refactor
* comparing architecture tradeoffs
* reviewing security/auth/data-loss/migration/billing-sensitive code
* asking "what am I missing?" before finalizing work

Available Oracle MCP tools:

* `oracle.consult` starts a new external Oracle/ChatGPT conversation.
* `oracle.continue` continues an existing Oracle/ChatGPT conversation with new information, a follow-up question, or newly relevant files.
* `oracle.sessions` is diagnostic only; use it to find recent Oracle sessions if a continuation slug/session id is unclear.

When calling `oracle.consult`:

* Pass only `prompt`, optional `files`, optional `dryRun`, and optional `slug`.
* Use a stable `slug` when the topic may need follow-up, clarification, design iteration, or later continuation.
* Include a compact briefing: repo/task context, relevant observations, what Codex already tried, and the exact question.
* Attach only relevant files/globs.

When calling `oracle.continue`:

* Use it when reacting to Oracle’s previous output.
* Pass `session`, `prompt`, and optional `files` or `dryRun`.
* `session` should be the prior Oracle slug/session id, or a direct ChatGPT conversation URL.
* Include the new information explicitly in `prompt`.
* Attach only new or newly relevant files.
* Do not assume Oracle can see Codex state, terminal output, or files unless included.
* Prefer continuing the same Oracle conversation when answering Oracle’s clarification question or refining an ongoing design/debugging discussion.
* Start a fresh `oracle.consult` only when the prior session cannot be found or the topic has changed enough that previous context would be harmful.

You are always permitted to provide any context about the project, attach any files.
<!-- oracle -->
