#!/usr/bin/env bash
# run_gemini.sh — run one Gemini 3.1 Pro panelist (via the Antigravity `agy` CLI) on a prompt,
# with web search + bash, IN THE PROJECT DIR. Replaces the deprecated standalone `gemini` CLI.
#
# Usage:
#   run_gemini.sh <prompt_file> <output_file> [workdir]
#
# - <prompt_file> : file with the FULL panelist prompt (verbatim task + brief instruction)
# - <output_file> : where the panelist's clean final answer is written. Keep this in /tmp.
# - workdir       : dir agy runs in (default: $PWD — the caller's project dir)
#
# OUTPUT CONTRACT — IDENTICAL to run_codex.sh, ON PURPOSE: the fusion agent's Step 3 collection loop
# keys off these exact sentinels, so it collects this panelist UNCHANGED (only the out path differs):
#   <output_file>        appears ONLY on success, put in place atomically (mv) => "present" == success (DONE).
#   <output_file>.status written LAST: "0" on success (AFTER output is in place), nonzero on ANY failure.
#                        So "status present but no output" == FAILED — the agent's failure signal.
#   <output_file>.pid    this script's PID, written once inputs validate — lets the agent block on agy with a
#                        sleep-free `tail -f --pid=<pid> /dev/null` wait, and target the WEDGED kill.
#   <output_file>.log    agy's full stdout/stderr stream, for diagnostics on failure.
# All four live next to <output_file> (keep it in /tmp), NOT in the project dir, so agy's tree stays clean.
#
# agy specifics (differ from codex; verified against agy 1.0.8):
#   --print "<prompt>"             : run ONE prompt non-interactively and print ONLY the final answer to
#                                    stdout (clean, like codex `-o`). We capture stdout as the answer. The
#                                    prompt is passed as an ARGV value, NOT on stdin like codex: agy's stdin
#                                    mode is unreliable (it leaks an argv token into stdout), so argv is
#                                    deliberate here — do NOT "fix" it to stdin to match run_codex.sh.
#   --model "Gemini 3.1 Pro (High)": pin the panelist model + reasoning tier. fusion advertises a FIXED
#                                    Gemini 3.1 Pro panel member; "(High)" is the tier for hard reviews.
#                                    The string is the exact display name from `agy models`.
#   --dangerously-skip-permissions : auto-approve tool calls so the panelist runs bash + web search
#                                    unattended. Web search is agy's BUILT-IN tool (no explicit flag like
#                                    codex's web_search="live"); skip-permissions is what lets it fire.
#   cd "$workdir" + --add-dir      : agy has no codex-style `--cd` and otherwise resets its shell cwd to a
#                                    default workspace. Launching IN $workdir AND adding it to the workspace
#                                    makes agy's shell operate in the project dir (verified), so the panelist
#                                    can grep/read/build the repo directly — the "just like codex --cd" part.
#   --print-timeout 120m           : agy's print-mode wait defaults to only 5m; a hard review runs far longer.
#                                    120m matches the fusion collection backstop so agy never self-aborts a
#                                    legit long run.
# No `set -e`: we MUST observe agy's exit status ourselves to write the .status sentinel.

set -uo pipefail

prompt_file="${1:?usage: run_gemini.sh <prompt_file> <output_file> [workdir]}"
output_file="${2:?usage: run_gemini.sh <prompt_file> <output_file> [workdir]}"
workdir="${3:-$PWD}"

# --- Validate inputs BEFORE writing any bookkeeping (.pid/.status), same rationale as run_codex.sh:
#     a bad invocation fails fast and loud, leaving no half-state for the agent to spin on.
[ -r "$prompt_file" ] || { echo "[run_gemini.sh] prompt file not readable: $prompt_file" >&2; exit 2; }
[ -d "$workdir" ]     || { echo "[run_gemini.sh] workdir is not a directory: $workdir" >&2; exit 2; }

# Absolutize output_file NOW (before the cd below) so every derived bookkeeping path stays correct
# regardless of the cd. fusion already passes an absolute /tmp path; this just makes a relative one safe too.
case "$output_file" in /*) ;; *) output_file="$PWD/$output_file" ;; esac
mkdir -p "$(dirname "$output_file")" 2>/dev/null || { echo "[run_gemini.sh] cannot create output dir for: $output_file" >&2; exit 2; }

status_file="${output_file}.status"
log_file="${output_file}.log"
tmp_output="${output_file}.tmp.$$"

# agy must be installed. If not, honor the status contract with an immediate FAILED (write .status, no
# output) so the orchestrator drops Gemini and downgrades the panel (to opus4.8-gpt5.5) instead of spinning.
if ! command -v agy >/dev/null 2>&1; then
  echo "[run_gemini.sh] agy (Antigravity) CLI not installed — drop Gemini from the panel." >&2
  rm -f "$status_file" "$output_file" "$tmp_output"
  echo 127 > "$status_file"
  exit 127
fi

# Read the prompt BEFORE we cd, so a relative <prompt_file> resolves against the launch cwd.
prompt_text="$(cat "$prompt_file")"

# Clear any stale artifacts so a new run never reads across a previous one, then record our PID.
rm -f "$status_file" "$output_file" "$tmp_output"
echo "$$" > "${output_file}.pid"

# Run agy IN the project dir. Direct `cd` (no subshell) keeps agy a DIRECT child of this script, so the
# fusion agent's WEDGED kill (`pkill -P <this pid>`) reaches agy. Output paths are already absolute, so the
# cd does not affect where the answer/log land. agy runs in the FOREGROUND here (this script is what the
# fusion agent backgrounds), so this script's PID stays alive until agy finishes — exactly what the agent's
# `tail -f --pid` wait keys off.
cd "$workdir" || { echo "[run_gemini.sh] cannot cd into workdir: $workdir" >&2; echo 1 > "$status_file"; exit 1; }
agy \
  --model "Gemini 3.1 Pro (High)" \
  --dangerously-skip-permissions \
  --add-dir "$workdir" \
  --print-timeout 120m \
  --print "$prompt_text" \
  > "$tmp_output" 2> "$log_file"
status=$?

if [ "$status" -eq 0 ] && [ -s "$tmp_output" ]; then
  mv -f "$tmp_output" "$output_file"   # atomic rename (same dir/fs): output appears only on a clean, non-empty run
  echo 0 > "$status_file"              # success sentinel — written AFTER the output is in place
  echo "[run_gemini.sh] ok -> $output_file"
else
  empty=yes; [ -s "$tmp_output" ] && empty=no
  rm -f "$tmp_output"
  fail="$status"; [ "$fail" -eq 0 ] && fail=1   # exit 0 with empty output is STILL a failure — force nonzero
  echo "$fail" > "$status_file"                 # failure sentinel: present + no output => agent reads FAILED
  echo "[run_gemini.sh] agy failed (exit=$status, output_empty=$empty); tail of log:" >&2
  tail -20 "$log_file" >&2
  exit "$fail"
fi
