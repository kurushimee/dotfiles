# Apply Code Review Findings (after `ce-code-review`)

Load this reference when Tier 2 `ce-code-review` has finished and **ce-work** (or another caller) should apply fixes before the Residual Work Gate.

`ce-code-review` is invoked here with `mode:agent`, so it is **review-only** in this context — it reports findings and writes artifacts and does not mutate the checkout, commit, push, or file tickets. **The caller owns apply/fix policy.** (In its own default/interactive mode the review applies safe fixes itself; that path does not apply here.)

## Consume the completed review (do not re-run it)

This reference loads **after** review has run. In the ce-work Tier 2 path, step 2a already invoked `ce-code-review`; this apply step **consumes that output** — do not start a second review, which would waste reviewer dispatches and risk overwriting the artifact the Residual Work Gate reconciles.

Reuse the review output already in hand:

- Parsed JSON (`status`, `actionable_findings`, `findings`, `artifact_path`, `run_id`) **or** the markdown Actionable Findings summary captured by the caller
- Run artifact dir: `/tmp/compound-engineering/ce-code-review/<run-id>/` (`review.json`, per-reviewer JSON for `why_it_matters`)

If `status` is `failed`, stop shipping and surface `reason`. If `degraded`, note partial reviewer coverage before applying anything.

### Fallback — invoke review only for cold callers

Only when the caller reached this file **without** already running review (no review output in hand): invoke `ce-code-review` once, then proceed to apply. Do not invoke when the caller already ran review (e.g., ce-work Tier 2 step 2a).

Invoke the skill explicitly — do not treat a casual "review my changes" prompt as a substitute unless the harness routed it to `ce-code-review`.

```
ce-code-review mode:agent plan:<plan-path> base:<merge-base-or-ref>
```

- `mode:agent` — JSON output (`review.json` + primary JSON response) for programmatic parsing; same review pipeline as default.
- `plan:` — when Phase 1 used a plan file (requirements completeness).
- `base:` — when the diff base is already resolved on the current checkout; omit when reviewing a PR number/URL or standalone current branch.
- Do **not** pass deprecated `mode:autofix`.

For human / interactive shipping, invoke `ce-code-review` without `mode:agent` if markdown tables are preferred. Capture the same JSON / Actionable Findings and artifact dir listed above before applying.

## Inputs for apply

- `actionable_findings` from JSON, or the Actionable Findings section from markdown
- Full finding detail when needed: `review.json` / artifact `findings`, or `{reviewer}.json` for `why_it_matters` and `evidence`
- Stable finding `#` — reuse in commits, residual sinks, and fork prompts

## What to apply

Default to applying every actionable finding. Applying is a reversible edit to a tracked tree; diffs are reviewed before commit (below) and tests run after — so leaving a clear, reversible fix unapplied "to be safe" is the failure mode, not the safe choice. Bias to act:

- **Apply** any finding with a concrete `suggested_fix` that is a clear improvement — the common case. `confidence` and `autofix_class` tell you what to prioritize and what to flag, not whether you may apply: `autofix_class` is signal, **never permission**.
- **Push back** — keep the finding, don't apply — when the reviewer is wrong; note why.
- **Flag, don't block, green-but-unverifiable edits** — when an applied fix touches auth/authz, a public or cross-service contract/schema, or concurrency, a passing test does not prove safety; apply it when there is a clear `suggested_fix` and confidence, and call it out prominently in the diff review.

There is no precondition safety checklist and no deny-list — a code-review fix is a reversible edit, so downside is controlled after the fact (diff review + tests + the commit checkpoint), not by gating the apply.

**Evidence still matches the code** — the fix fork confirms at `file:line` before editing. The orchestrator does **not** open files just to decide eligibility or dispatch.

## What to defer (to the Residual Work Gate)

- `autofix_class: advisory` — report-only.
- Findings with no concrete `suggested_fix` to act on.
- Findings whose right fix depends on a design or product decision — architecture direction, contract shape, or a behavior change needing sign-off. These need a human call before code changes.

Surface what was deferred and why; never silently drop.

## Execution — orchestrator batches, forks apply

The orchestrator **does not investigate findings** (no pre-read of cited files to judge complexity or inline vs fork). That would spend the context window you are trying to protect.

**Orchestrator owns:** parse review output → **eligibility filter on JSON fields only** → build batches → dispatch `effort: balanced` fix forks → review diffs → tests → commit → Residual Work Gate.

**Fix forks own:** read `file:line`, confirm evidence still matches, apply or skip with reason, return summary.

### Default: batched fix forks

After eligibility filtering, **dispatch forks for all remaining applicable findings** unless the optional inline shortcut below applies. Do not classify findings by complexity in the parent thread.

**Batching (primary rule — group by file):**

1. Sort applicable findings by severity (P0 first).
2. **Group by `file`.** All eligible findings on the same file → **one fork** (it loads the file once and works through its `#` list in severity order).
3. **Dispatch:** forks editing the same file run one at a time (same-file collision). Disjoint-file batches may run in parallel. After each fork returns, review its diff, verify, commit when appropriate, and only then dispatch the next batch that depends on that result.
4. **Same file, many findings:** keep one fork per file. If the prompt would exceed a comfortable size (~8 findings), split into sequential fork passes on that file (first batch highest severity, then next batch after the prior fork returns and verification passes).
5. **Cross-file coupling:** do not merge unrelated files into one fork just to reduce fork count — file grouping is the default. Only co-batch multiple files when findings explicitly reference the same small edit surface (rare); when in doubt, separate by file.

**Fork prompt (per batch):** the assigned findings only (`#`, severity, file, line, title, `suggested_fix`, `requires_verification`; add `why_it_matters` from `{reviewer}.json` in the run artifact when useful), plus:
- Work through assigned `#` in severity order; at each `file:line`, skip with a one-line reason if evidence no longer matches
- Apply the mechanical bar from § What to apply / What not to apply — skip anything that needs design judgment
- Do not re-run `ce-code-review`
- Do not stage or commit — return which `#` were applied or skipped and which files changed

**After each fork:** orchestrator reviews diffs (scope = assigned `#` only), runs tests (`requires_verification: true` on any applied finding → at least targeted tests; multi-file → broader suite), commits (`fix(review): apply findings #…`) when appropriate, then proceeds to the next batch.

### Optional inline shortcut (skip fork dispatch)

Use **only** when **all** of the following hold:

- Exactly **one** eligible finding after JSON filtering, **and**
- The orchestrator **already** has that file's relevant region in context from Phase 2 work this session (no new Read/Grep expedition)

Otherwise dispatch an `effort: balanced` fork — even for a single finding. When unsure, dispatch.

### Summary (required)

Report: batches dispatched, `#` applied vs skipped (with reasons from forks), artifact path, tests run.

## Handoff to Residual Work Gate

Any actionable finding not applied in this pass is **residual work** — proceed to the Residual Work Gate with an updated count. Do not re-invoke `ce-code-review` solely to re-apply the same findings unless the diff changed materially after fixes.
