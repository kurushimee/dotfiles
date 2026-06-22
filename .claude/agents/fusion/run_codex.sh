#!/usr/bin/env bash
# run_codex.sh — run one GPT-5.5 panelist (via codex) on a prompt, with LIVE web search + bash.
#
# Usage:
#   run_codex.sh <prompt_file> <output_file> [reasoning_effort] [workdir]
#
# - <prompt_file>   : path to a file containing the FULL panelist prompt (verbatim task + brief instruction)
# - <output_file>   : where the panelist's final answer is written (clean, just the answer). Keep this in /tmp.
# - reasoning_effort: low | medium | high | xhigh  (default: high)
# - workdir         : dir codex runs in (default: $PWD — the caller's project dir)
#
# OUTPUT CONTRACT — the fusion agent's Step 3 collection loop depends on this EXACTLY:
#   <output_file>         appears ONLY on success, put in place atomically (mv) — so on disk
#                         "output present" <=> "codex succeeded". The agent keys DONE off this.
#   <output_file>.status  written LAST: "0" on success (AFTER the output is in place), nonzero on ANY
#                         failure (including an exit-0 run that produced no final message). So
#                         "status present but no output" <=> "failed" — that is the agent's FAILED signal.
#   <output_file>.pid     this script's PID, written once inputs validate — lets the agent block on codex
#                         with a sleep-free `tail -f --pid=<pid> /dev/null` wait.
#   <output_file>.log     codex's full stdout/stderr stream, for diagnostics on failure.
# All four live next to <output_file> (keep that in /tmp), NOT in the project dir, so codex's working
# tree stays the clean repo.
#
# Notes:
# - `-o/--output-last-message` writes ONLY the agent's final message — no streaming noise to parse.
# - `-s workspace-write` lets the panelist run shell commands (the "bash tool") and explore the repo.
# - codex runs IN THE PROJECT DIR (workdir) so it can grep/read/build and hunt down missed context
#   directly — no scratch dir, no copying files in.
# - No `set -e`: we MUST observe codex's exit status ourselves to write the .status sentinel.

set -uo pipefail

prompt_file="${1:?usage: run_codex.sh <prompt_file> <output_file> [reasoning_effort] [workdir]}"
output_file="${2:?usage: run_codex.sh <prompt_file> <output_file> [reasoning_effort] [workdir]}"
effort="${3:-high}"
workdir="${4:-$PWD}"

# --- Validate inputs BEFORE writing any bookkeeping (.pid/.status). The fusion agent treats the pid
#     file as "launch underway"; if we wrote it and THEN died on a bad arg, the agent could spin on a
#     dead pid. Validating first means a bad invocation fails fast and loud, leaving no half-state.
#     (With no .pid/.status written, the agent sees PID_NOT_READY and — after its bounded retries —
#     reads this stderr from the background task output.)
[ -r "$prompt_file" ] || { echo "[run_codex.sh] prompt file not readable: $prompt_file" >&2; exit 2; }
case "$effort" in low|medium|high|xhigh) ;; *) echo "[run_codex.sh] bad reasoning_effort (want low|medium|high|xhigh): $effort" >&2; exit 2 ;; esac
[ -d "$workdir" ] || { echo "[run_codex.sh] workdir is not a directory: $workdir" >&2; exit 2; }
mkdir -p "$(dirname "$output_file")" 2>/dev/null || { echo "[run_codex.sh] cannot create output dir for: $output_file" >&2; exit 2; }

status_file="${output_file}.status"
log_file="${output_file}.log"
tmp_output="${output_file}.tmp.$$"
# Clear any stale artifacts at this path so a new run never reads across a previous one.
rm -f "$status_file" "$output_file" "$tmp_output"

# Write THIS script's PID next to the output file. `codex exec` below runs in the foreground, so this
# PID stays alive until codex finishes — the agent's `tail -f --pid` wait returns exactly then.
echo "$$" > "${output_file}.pid"

# Flags:
#   -m gpt-5.5            : pin the panelist model. fusion advertises a FIXED GPT-5.5 panel member, so
#                          pin it explicitly — if a future codex changes its priority-0 default model,
#                          this fails LOUD rather than silently swapping in a different panelist.
#   -s workspace-write    : let the panelist run shell + explore the repo. DELIBERATELY narrower than
#                          codex's global default (danger-full-access): a reviewer needs read/grep/build,
#                          not the whole machine. Do NOT "fix" this to match the global config.
#   -c web_search="live"  : LIVE web search (fetch current pages). The legacy boolean form enabled only
#                          the cached index; under -s workspace-write codex would otherwise default to
#                          cached. "live" is the modern key and the right mode for a reviewer checking
#                          current docs/specs.
#   -o <tmp_output>       : write ONLY the agent's final message — to a TEMP file we atomically mv into
#                          place on success, so the agent never sees a half-written or post-failure
#                          output file as "done".
codex exec \
  --skip-git-repo-check \
  --cd "$workdir" \
  -m gpt-5.5 \
  -s workspace-write \
  -c 'web_search="live"' \
  -c "model_reasoning_effort=$effort" \
  -o "$tmp_output" \
  - < "$prompt_file" \
  > "$log_file" 2>&1
status=$?

if [ "$status" -eq 0 ] && [ -s "$tmp_output" ]; then
  mv -f "$tmp_output" "$output_file"   # atomic rename (same dir/fs): output appears only on a clean, non-empty run
  echo 0 > "$status_file"              # success sentinel — written AFTER the output is in place
  echo "[run_codex.sh] ok -> $output_file"
else
  empty=yes; [ -s "$tmp_output" ] && empty=no
  rm -f "$tmp_output"
  fail="$status"; [ "$fail" -eq 0 ] && fail=1   # exit 0 with empty output is STILL a failure — force nonzero
  echo "$fail" > "$status_file"                 # failure sentinel: present + no output => agent reads FAILED
  echo "[run_codex.sh] codex failed (exit=$status, output_empty=$empty); tail of log:" >&2
  tail -20 "$log_file" >&2
  exit "$fail"
fi
