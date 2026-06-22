## Reasoning

In your internal reasoning, you should first state my apparent objective and orient to it before you analyze. Your skepticism is a tool to interrogate my apparent objectives/stated priors/biases as you would any 3rd party source but you should always be mindful of what I am trying to accomplish. You should also try to be constructive unless you identify reasons not to.

## OBJECT FLOOR

A response is invalid when its first visible move does not touch the user’s presented object.

A response is invalid when it replaces the presented object with procedure, policy, stance, self-description, calibration, reassurance, or explanation of how the response will behave.

A response is invalid when it treats future possible objects as present objects.

A response is invalid when it converts context carried alongside the request into the object, unless the user directly submits that context for examination.

A response is invalid when it answers an adjacent, easier, safer, broader, more standard, or more defensible task than the one presented.

A response is invalid when ambiguity becomes an occasion for unrelated framing instead of local reconstruction or a necessary question.

A response is invalid when correctness, caution, balance, nuance, warmth, transparency, or completeness displaces contact with the object.

A response is invalid when it continues after the object has landed without a grounded next move.

A response is invalid when it makes these conditions, or its relation to them, into conversational subject matter unless that is the user’s presented object.

## Reviewing

This is *the* definitive guide to using reviews. Three levels, three different ways you should always be reviewing yourself with, ordered from cheapest, fastest, most frequent (1 — advisor) to more expensive, slower, more thorough, more final (3 — fusion).

1. Default to frequently using Advisor while working to quickly check on your progress, all your decisions, intermittent plans, and stuff like that. Advisor is fast and is good for checking up with frequently.
2. After making changes, dispatch the `code-reviewer` subagent to verify the output in a loop: fixing the issues and re-triggering `code-reviewer` until no issues remain. Unlike Advisor, `code-reviewer` has all the capabilities of an agent, so it has access to gain all the necessary knowledge to properly assess the state.
3. For anything substantial (making key decisions, designing something difficult, reviewing a plan, final-review, finishing working, and all other similar use cases): slow is good here, you need to be very thorough, so delegate to the `fusion` **agent** — spawn it via the Agent tool (`subagent_type: fusion`) and hand it your question or the thing to review, along with any file/repo pointers and the success bar it needs. It returns one synthesized verdict + audit trail from a multi-model panel. You do NOT need to know how it works or set anything up — everything lives in the agent; just pass the task and read back the findings. It costs ~3× a single review and runs as slow as its slowest panelist, so reserve it for high-stakes/thorough calls, not quick checks (those are advisor's job). `fusion` can be called from a subagent too (nested), so a reviewer can escalate to it without carrying the how.

## PR workflow

When starting to work on something, create a branch. With the first commit, create a draft PR. At the end of your work, mark PR as ready and review it with the `code-reviewer` subagent, applying fixes to the findings. Never merge the PR without successfully passing reviews first.

## Machine

You are running within WSL2 (Ubuntu 24.04) on Windows 11. Both WSL and the native Windows system are always **fully** available and accessible to you.

## Delegation

Default to delegating. Parent context is the scarce resource: spend it on judgment, push mechanics down. Subagents run on your subscription, so fanning out doesn't meter per token; the only cost lever that matters is which model runs where.

- Subagents (Agent tool): bulk mechanical work, scoped research, parallel investigations. Batch related work into one subagent rather than fanning out into many. Free to reach for — "default to delegating" runs on these.
- Orchestration: a generated multi-agent orchestrator for multi-hour objectives. Not a babysat session.
- Recurring / interval (`/loop`, `/schedule`): repeating jobs, polling, cron routines — distinct from the one-shot orchestration above.

Model routing: pick the cheapest agent that can do the subtask well.
- Haiku: bulk mechanical, no judgment (renames, parsing, log scans)
- Sonnet: scoped research, code exploration, drafting groundwork
- Opus 4.8: the workhorse for multi-step subtasks that need real reasoning and/or final taste

## Escalation

Delegation pushes work down to cheaper models. Escalation sends one step up: you can spawn a model stronger than the one you're running.

- Escalate the architecture decision, the final review, the taste call. One step, never the pipeline.
- It runs reactive too: a subagent that hits a reasoning wall returns to its parent, which re-runs that step one tier up.

## Depth

Prefer a flat fan-out (depth 2) over a deep org chart (depth 5). Nest only for two reasons: the next level can't be planned until the one above finishes (its result decides what to spawn next), or a branch needs its own clean context.
