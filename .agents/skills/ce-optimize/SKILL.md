---
name: ce-optimize
description: "Run metric-driven iterative optimization loops -- define a measurable goal, run serial experiments, measure each against hard gates or LLM-as-judge scores, keep improvements, and converge on the best solution. Use when optimizing clustering quality, search relevance, build performance, prompt quality, or any measurable outcome that benefits from systematic experimentation."
argument-hint: "[path to optimization spec YAML, or describe the optimization goal]"
---

# Iterative Optimization Loop

Run metric-driven iterative optimization. Define a goal, build measurement scaffolding, then run one experiment at a time with a focused fork, measure it, keep or revert it, and use the logged result to choose the next hypothesis.

## Interaction Method

Use the platform's blocking question tool: `AskUserQuestion` in Claude Code (call `ToolSearch` with `select:AskUserQuestion` first if its schema isn't loaded), `request_user_input` in Codex, `ask_question` in Antigravity CLI (`agy`), `ask_user` in Pi (requires the `pi-ask-user` extension). Fall back to numbered options in chat only when no blocking tool exists in the harness or the call errors (e.g., Codex edit modes) — not because a schema load is required. Never silently skip the question.

## Input

<optimization_input> #$ARGUMENTS </optimization_input>

If the input above is empty, ask: "What would you like to optimize? Describe the goal, or provide a path to an optimization spec YAML file."

## Optimization Spec Schema

Reference the spec schema for validation:

`references/optimize-spec-schema.yaml`

## Experiment Log Schema

Reference the experiment log schema for state management:

`references/experiment-log-schema.yaml`

## Quick Start

For a first run, optimize for signal and safety:

- Start from `references/example-hard-spec.yaml` when the metric is objective and cheap to measure
- Use `references/example-judge-spec.yaml` only when actual quality requires semantic judgment
- Use `execution.mode: serial`
- Cap the first run with `stopping.max_iterations: 4` and `stopping.max_hours: 1`
- Avoid new dependencies until the baseline and measurement harness are trusted
- For judge mode, start with `sample_size: 10`, `batch_size: 5`, and `max_total_cost_usd: 5`

For a friendly overview of what this skill is for, when to use hard metrics vs LLM-as-judge, and example kickoff prompts, see:

`references/usage-guide.md`

---

## Persistence Discipline

**CRITICAL: The experiment log on disk is the single source of truth. The conversation context is NOT durable storage. Results that exist only in the conversation WILL be lost.**

The files under `.context/compound-engineering/ce-optimize/<spec-name>/` are local scratch state. They are ignored by git, so they survive local resumes on the same machine but are not preserved by commits, branches, or pushes unless the user exports them separately.

This skill runs for hours. Context windows compact, sessions crash, and agents restart. Every piece of state that matters MUST live on disk, not in the agent's memory.

**If you produce a results table in the conversation without writing those results to disk first, you have a bug.** The conversation is for the user's benefit. The experiment log file is for durability.

### Core Rules

1. **Write each experiment result to disk IMMEDIATELY after measurement** — not after evaluation, IMMEDIATELY. Append the experiment entry to the experiment log file the moment its metrics are known, before evaluating the next experiment.
2. **VERIFY every critical write** — after writing the experiment log, read the file back and confirm the entry is present. Do not proceed to the next experiment until verification passes.
3. **Re-read from disk at every phase boundary and before every decision** — never trust in-memory state across phase transitions or after any operation that might have taken significant time.
4. **Keep the checkout healthy between experiments** — start each experiment from a clean tree, and after measuring either commit the winning diff or revert the experiment before continuing.
5. **Per-experiment result markers for crash recovery** — each experiment writes a `result.yaml` marker under `.context/compound-engineering/ce-optimize/<spec-name>/experiments/<iteration>/` immediately after measurement. On resume, scan for markers not yet reflected in the log.
6. **Strategy digest is written after every evaluation step before generating new hypotheses** — the agent reads the digest, not its memory, when deciding what to try next.
7. **Never present results to the user without writing them to disk first** — the pattern is: measure -> write to disk -> verify -> THEN show the user.

### Mandatory Disk Checkpoints

| Checkpoint | File Written | Phase |
|---|---|---|
| CP-0: Spec saved | `spec.yaml` | Phase 0, after user approval |
| CP-1: Baseline recorded | `experiment-log.yaml` (initial with baseline) | Phase 1, after baseline measurement |
| CP-2: Hypothesis backlog saved | `experiment-log.yaml` (hypothesis_backlog section) | Phase 2, after hypothesis generation |
| CP-3: Each experiment result | `experiment-log.yaml` (append experiment entry) + `experiments/<iteration>/result.yaml` | Phase 3.3, immediately after each measurement |
| CP-4: Evaluation summary | `experiment-log.yaml` (outcome + best) + `strategy-digest.md` | Phase 3.5, after each experiment evaluation |
| CP-5: Final summary | `experiment-log.yaml` (final state) | Phase 4, at wrap-up |

**Format of a verification step:**
1. Write the file using the native file-write tool
2. Read the file back using the native file-read tool
3. Confirm the expected content is present
4. If verification fails, retry the write. If it fails twice, alert the user.

### File Locations (all under `.context/compound-engineering/ce-optimize/<spec-name>/`)

| File | Purpose | Written When |
|------|---------|-------------|
| `spec.yaml` | Optimization spec (immutable during run) | Phase 0 (CP-0) |
| `experiment-log.yaml` | Full history of all experiments | Initialized at CP-1, appended at CP-3, updated at CP-4 |
| `strategy-digest.md` | Compressed learnings for hypothesis generation | Written at CP-4 after each experiment |
| `experiments/<iteration>/result.yaml` | Per-experiment crash-recovery marker | Immediately after measurement, before CP-3 verification |

### On Resume

When Phase 0.4 detects an existing run:
1. Read the experiment log from disk — this is the ground truth
2. Scan `experiments/*/result.yaml` markers not yet reflected in the log
3. Recover any measured-but-unlogged experiments
4. Confirm the git tree is clean before selecting the next experiment
5. Continue from where the log left off

---

## Phase 0: Setup

### 0.1 Determine Input Type

Check whether the input is:
- **A spec file path** (ends in `.yaml` or `.yml`): read and validate it
- **A description of the optimization goal**: help the user create a spec interactively

### 0.2 Load or Create Spec

**If spec file provided:**
1. Read the YAML spec file. The orchestrating agent parses YAML natively -- no shell script parsing.
2. Validate against `references/optimize-spec-schema.yaml`:
   - All required fields present
   - `name` is lowercase kebab-case and safe to use in git refs / run paths
   - `metric.primary.type` is `hard` or `judge`
   - If type is `judge`, `metric.judge` section exists with `rubric` and `scoring`
   - At least one degenerate gate defined
   - `measurement.command` is non-empty
   - `scope.mutable` and `scope.immutable` each have at least one entry
   - Gate check operators are valid (`>=`, `<=`, `>`, `<`, `==`, `!=`)
   - `execution.mode` is `serial`
3. If validation fails, report errors and ask the user to fix them

**If description provided:**
1. Analyze the project to understand what can be measured.
2. Detect whether the optimization target is qualitative or quantitative:
   - Use `type: hard` when the metric is an objectively measurable scalar (build time, test pass rate, latency, memory, bundle size).
   - Use `type: judge` when output quality requires semantic judgment (clustering quality, search relevance, summarization quality, code readability, UX copy, recommendations).
   - For qualitative targets, strongly recommend `type: judge` with degenerate gates, judge scoring, and diagnostics.
3. For `type: judge`, design the sampling strategy:
   - Define what one sampled item is.
   - Choose strata that cover the important output surface.
   - Pick a first-run sample size that balances cost and signal.
   - Add singleton sampling when coverage/false-negative quality matters.
4. For `type: judge`, design a concrete rubric with a 1-5 scale or equivalent, supplementary diagnostic fields, and JSON-return instructions.
5. Guide the user through the remaining spec fields:
   - Degenerate gates
   - Measurement command
   - Mutable and immutable paths
   - Constraints and approved dependencies
   - `execution.mode: serial`
   - First-run stopping limits
   - Judge sample size, batch size, and cost cap
6. Write the spec to `.context/compound-engineering/ce-optimize/<spec-name>/spec.yaml`.
7. Present the spec to the user for approval before proceeding.

### 0.3 Search Prior Learnings

Read `references/agents/learnings-researcher.md` and dispatch one `effort: fast` generic fork seeded with that local prompt to search for prior optimization work on similar topics. If relevant learnings exist, incorporate them into the approach.

### 0.4 Resume Detection

Check for `.context/compound-engineering/ce-optimize/<spec-name>/experiment-log.yaml`.

If it exists:
1. Read `experiment-log.yaml` and `strategy-digest.md` if present.
2. Scan `.context/compound-engineering/ce-optimize/<spec-name>/experiments/*/result.yaml` for measured results absent from the log.
3. Recover missing entries before continuing.
4. Ask the user whether to resume or start a fresh run. Starting fresh creates a new `<spec-name>-<timestamp>` run directory unless the user explicitly wants to overwrite local scratch state.

---

## Phase 1: Baseline

### 1.1 Clean Tree Check

Run:

```bash
git status --porcelain
```

If the tree is dirty, ask the user whether to commit, stash, or stop. Do not begin baseline measurement or experiments from a dirty tree.

### 1.2 Validate Measurement Harness

Run the measurement command from the repo root or configured `measurement.working_directory`:

```bash
bash scripts/measure.sh "<measurement.command>" <timeout_seconds> "<measurement.working_directory or .>" <env_vars...>
```

The measurement command must output JSON containing:
- All degenerate gate metric keys
- All diagnostic metric keys
- The primary metric key when `metric.primary.type: hard`

If it fails or emits malformed JSON, stop and ask the user to fix the harness.

### 1.3 Baseline Measurement

Run the measurement command on the clean baseline.

If stability mode is `repeat`, run the measurement harness `repeat_count` times and aggregate exactly according to the spec (`median`, `mean`, `min`, or `max`). Use the aggregate as the baseline and record per-run values in diagnostics when useful.

If primary type is `judge`, also run the judge evaluation on baseline output to establish the starting judge score. Judge batches are evaluated with `references/judge-prompt-template.md` at `effort: balanced`; independent batches run in parallel, then aggregate after all return.

### 1.4 Write Baseline to Disk (CP-1)

Before presenting results to the user, write the initial experiment log with baseline metrics to disk:

1. Create `.context/compound-engineering/ce-optimize/<spec-name>/experiment-log.yaml`.
2. Include all required top-level sections from `references/experiment-log-schema.yaml`: `spec`, `run_id`, `started_at`, `baseline`, `experiments`, and `best`.
3. Seed `experiments` as an empty array and seed `best` from the baseline snapshot (`iteration: 0`).
4. Optionally seed `hypothesis_backlog: []` so the log shape is stable before Phase 2 populates it.
5. Verify by reading the file back and confirming the required sections and baseline values.
6. Only then present results to the user.

### 1.5 User Approval Gate

Present to the user via the platform question tool:

- Baseline metrics: all gate values, diagnostic values, and judge scores if applicable
- Experiment log location
- Clean-tree status
- Judge budget: estimated per-experiment judge cost and configured `max_total_cost_usd` cap, or an explicit note that spend is uncapped

Options:
1. **Proceed** -- approve baseline and move to Phase 2
2. **Adjust spec** -- modify spec settings before proceeding
3. **Fix issues** -- user needs to resolve blockers first

Do not proceed to Phase 2 until the user explicitly approves. If primary type is `judge` and `max_total_cost_usd` is null, call that out as uncapped spend and require explicit approval.

After approval, re-read the spec and baseline from disk.

---

## Phase 2: Hypothesis Generation

### 2.1 Analyze Current Approach

Read the code within `scope.mutable` to understand:
- The current implementation approach
- Obvious improvement opportunities
- Constraints and dependencies between components

Optionally read `references/agents/repo-research-analyst.md` and dispatch one `effort: fast` generic fork seeded with that local prompt for deeper codebase analysis if the scope is large or unfamiliar. Incorporate its findings before generating hypotheses.

### 2.2 Generate Hypothesis List

Generate an initial set of hypotheses. Each hypothesis should have:
- **Description**: what to try
- **Category**: one of the standard categories (signal-extraction, graph-signals, embedding, algorithm, preprocessing, parameter-tuning, architecture, data-handling) or a domain-specific category
- **Priority**: high, medium, or low based on expected impact and feasibility
- **Required dependencies**: any new packages or tools needed

Include user-provided hypotheses if any were given as input. Aim for 10-30 hypotheses in the initial backlog. More can be generated during the loop based on learnings.

### 2.3 Dependency Pre-Approval

Collect all unique new dependencies across all hypotheses.

If any hypotheses require new dependencies:
1. Present the full dependency list to the user via the platform question tool.
2. Ask for bulk approval.
3. Mark each hypothesis's `dep_status` as `approved` or `needs_approval`.

Hypotheses with unapproved dependencies remain in the backlog but are skipped during selection. They are re-presented at wrap-up for potential approval.

### 2.4 Record Hypothesis Backlog (CP-2)

Write the initial backlog to the experiment log file and verify:

```yaml
hypothesis_backlog:
  - description: "Remove template boilerplate before embedding"
    category: "signal-extraction"
    priority: high
    dep_status: approved
    required_deps: []
```

---

## Phase 3: Optimization Loop

This phase repeats until a stopping criterion is met.

### 3.1 Select the Next Hypothesis

Select one hypothesis:
- Exclude hypotheses with `dep_status: needs_approval`.
- Prefer high-priority hypotheses.
- Prefer category diversity across recent experiments.
- Avoid retrying approaches that the strategy digest says failed.

If the backlog is empty and no new hypotheses can be generated, proceed to Phase 4. If the backlog is non-empty but no runnable hypotheses remain because everything needs approval or is otherwise blocked, proceed to Phase 4 so the user can approve dependencies instead of spinning.

### 3.2 Dispatch One Experiment Fork

Experiments are open-ended implementation under a hypothesis — dispatch the experiment fork at `effort: deep`, one at a time. Before dispatch:
1. Re-read `experiment-log.yaml`, `strategy-digest.md`, and `spec.yaml` from disk.
2. Run `git status --porcelain` and require a clean tree.
3. Fill `references/experiment-prompt-template.md` with:
   - Iteration number and spec name
   - Hypothesis description and category
   - Current best and baseline metrics
   - Mutable and immutable scope
   - Constraints and approved dependencies
   - Rolling window of last 10 experiments (concise summaries)

Dispatch one `effort: deep` generic fork with the filled prompt. The fork implements only that hypothesis, edits only mutable-scope files, does not run the measurement harness, and does not commit.

When the fork returns:
1. Inspect `git diff --stat` and `git diff -- <scope.mutable>`.
2. Confirm all changed files are within mutable scope. Revert out-of-scope edits before measuring.
3. If the fork reports an unapproved dependency need, revert any partial diff, mark the experiment `deferred_needs_approval`, persist it, and select the next hypothesis.

### 3.3 Measure and Persist Results

For the completed experiment, immediately:

1. **Run measurement** in the configured working directory:
   ```bash
   bash scripts/measure.sh "<measurement.command>" <timeout_seconds> "<measurement.working_directory or .>" <env_vars...>
   ```
   If stability mode is `repeat`, run the measurement harness `repeat_count` times and aggregate exactly as in Phase 1.

2. **Write crash-recovery marker** — create `.context/compound-engineering/ce-optimize/<spec-name>/experiments/<iteration>/result.yaml` containing raw metrics, aggregate metrics, measurement timestamp, changed files, and the hypothesis.

3. **Evaluate degenerate gates**:
   - Parse each gate's operator and threshold.
   - Compare the metric value against the threshold.
   - If any gate fails, mark outcome `degenerate` and skip judge evaluation.

4. **If gates pass and primary type is `judge`**:
   - Read the experiment's output.
   - Apply stratified sampling per `metric.judge.stratification` using `sample_seed`.
   - Group samples into batches of `metric.judge.batch_size`.
   - Fill `references/judge-prompt-template.md` for each batch.
   - Dispatch one `effort: balanced` judge fork per batch; independent sample batches run in parallel, then aggregate the returned JSON scores.
   - If `singleton_sample > 0`, evaluate singleton batches the same way.

5. **If gates pass and primary type is `hard`**:
   - Use the metric value directly from the measurement output.

6. **Append to experiment log on disk (CP-3)** — write the experiment entry with outcome `measured`, `degenerate`, `error`, `timeout`, or `deferred_needs_approval` as appropriate. Include iteration, hypothesis, changed files, metrics, gates, diagnostics, judge scores, learnings, and error details when present.

7. **Verify CP-3** — read the experiment log back and confirm the entry is present. Do not proceed until confirmed.

### 3.4 Evaluate the Experiment

For an experiment with outcome `measured`:

1. Compare the primary metric to the current best:
   - For hard metrics, apply `metric.primary.direction` and require the absolute improvement to exceed `measurement.stability.noise_threshold`.
   - For judge metrics, compare the configured primary judge score and require it to exceed `minimum_improvement`.
2. If the experiment improves on current best:
   - Stage only mutable-scope changes.
   - Commit with `optimize(<spec-name>): <hypothesis description>`.
   - Update the experiment outcome to `kept` and record the commit SHA.
   - Update the `best` section in the experiment log.
3. If the experiment does not improve:
   - Revert the experiment diff.
   - Update the experiment outcome to `reverted`.
4. If the experiment is `degenerate`, `error`, `timeout`, or `deferred_needs_approval`:
   - Revert any experiment diff unless the outcome already committed nothing.
   - Keep the terminal outcome in the log.
5. Verify the tree is clean before proceeding.

### 3.5 Update State (CP-4)

After each experiment evaluation:

1. Re-read the experiment log from disk.
2. Update the finalized outcome and `best` section if needed.
3. Write `strategy-digest.md` with:
   - Categories tried so far and success/failure counts
   - Key learnings from this experiment and overall
   - Exploration frontier: categories and approaches remaining
   - Current best metrics and improvement from baseline
4. Generate new hypotheses if the backlog is thin:
   - Re-read the strategy digest from disk.
   - Read the rolling window of the last 10 experiments from the log.
   - Add new hypotheses to `hypothesis_backlog` without retrying failed approaches.
5. Verify both files after writing.

### 3.6 Stopping Criteria

After CP-4, stop when any configured criterion is met:
- `stopping.max_iterations`
- `stopping.max_hours`
- `stopping.plateau_iterations`
- `stopping.target_reached`
- Judge cost cap reached
- No runnable hypotheses remain

When none are met, return to Phase 3.1.

---

## Phase 4: Wrap-Up

### 4.1 Final Verification

Run the measurement command on the final kept state and record final metrics. For judge mode, run final judge evaluation if budget remains and the user approves any additional uncapped cost.

### 4.2 Write Final Summary (CP-5)

Update the experiment log with final state:
- Final best metrics and judge scores
- Total experiments attempted
- Kept, reverted, degenerate, errored, timeout, and deferred counts
- Total judge cost
- Open hypotheses and dependency approvals still needed

Verify the write.

### 4.3 Present Results

Report:
- Baseline vs final metrics
- Best experiment and commit SHA
- Experiment log path and strategy digest path
- Important learnings
- Deferred dependency requests
- Any caveats about metric noise, judge ambiguity, or unvalidated quality dimensions

---

## Included References

- `references/optimize-spec-schema.yaml`
- `references/experiment-log-schema.yaml`
- `references/experiment-prompt-template.md`
- `references/judge-prompt-template.md`
- `references/usage-guide.md`
