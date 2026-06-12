#!/bin/bash
# =============================================================================
# PostToolUse hook: Run linter after file writes.
#
# Hook event: PostToolUse (matcher: Write|Edit|MultiEdit)
# Automatically lints files after Claude Code writes them,
# catching issues before they accumulate.
#
# Supported linters:
#   - JavaScript/JSX: ESLint (requires eslint config in project)
#   - Python: ruff (must be installed: pip install ruff)
#   - Rust: cargo clippy (requires Cargo.toml; lints the whole crate)
#   - GDScript: gdlint (must be installed: pip install gdtoolkit)
#
# Customize:
#   - Add new file extensions and their linters in the case block
#   - Adjust --max-warnings threshold for strictness
#   - Add TypeScript, Go, Rust, etc. linters as needed
# =============================================================================

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE" ] && exit 0

EXT="${FILE##*.}"

# ESLint config detection -- covers the common names. `npx eslint` will also
# pick up `eslintConfig` in package.json on its own, so we don't need to probe that.
has_eslint_config() {
  for cfg in .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json \
             .eslintrc.yml .eslintrc.yaml \
             eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts; do
    [ -f "$cfg" ] && return 0
  done
  return 1
}

case "$EXT" in
  js|jsx|ts|tsx|mjs|cjs)
    has_eslint_config && npx eslint "$FILE" --max-warnings 5 2>&1 | head -20 || true
    ;;
  py)
    command -v ruff &>/dev/null && ruff check "$FILE" 2>&1 | head -20 || true
    ;;
  rs)
    # Clippy works per-crate, not per-file, so we run it from the file's
    # directory and let cargo locate the enclosing Cargo.toml.
    if command -v cargo &>/dev/null; then
      ( cd "$(dirname "$FILE")" && cargo clippy --quiet 2>&1 | head -20 ) || true
    fi
    ;;
  gd)
    command -v gdlint &>/dev/null && gdlint "$FILE" 2>&1 | head -20 || true
    ;;
  # Add more linters here:
  # go) go vet "$FILE" 2>&1 | head -20 || true ;;
esac
exit 0
