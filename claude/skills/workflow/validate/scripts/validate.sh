#!/usr/bin/env bash
# Run a project's full validation suite in dependency order.
# Auto-detects the package manager (by lockfile) and which package.json scripts
# exist, runs build/typecheck/test/lint/format, and reports per step.
#
# Flags:
#   --all         run every step and report all failures at the end (default: fast-fail)
#   --with-e2e    include the end-to-end test step (off by default: slow)
#   --no-frozen   allow lockfile churn on install (default: frozen/ci install)
#
# Output contract (for skill-to-skill use):
#   exit 0 + "PASS" line  -> all green
#   any non-zero exit     -> FAIL; the failing step is named

set -uo pipefail   # not -e: failure is handled per step

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "FAIL: not inside a git repository" >&2; exit 1; }
cd "$ROOT"

FAST_FAIL=1; WITH_E2E=0; FROZEN=1
for a in "$@"; do
  case "$a" in
    --all) FAST_FAIL=0 ;;
    --with-e2e) WITH_E2E=1 ;;
    --no-frozen) FROZEN=0 ;;
    *) echo "unknown flag: $a (use --all, --with-e2e, --no-frozen)" >&2; exit 2 ;;
  esac
done

step() { printf '\n\033[1;34m> %s\033[0m\n' "$1"; }
ok()   { printf '\033[1;32mok  %s\033[0m\n' "$1"; }
skip() { printf '\033[2m--  skip %s (no script)\033[0m\n' "$1"; }
fail() { printf '\033[1;31mFAIL: %s\033[0m\n' "$1" >&2; }

# Package manager by lockfile.
if   [ -f bun.lockb ] || [ -f bun.lock ]; then PM=bun
elif [ -f pnpm-lock.yaml ]; then PM=pnpm
elif [ -f yarn.lock ]; then PM=yarn
elif [ -f package-lock.json ]; then PM=npm
elif [ -f package.json ]; then PM=npm
else echo "FAIL: no supported toolchain (no JS lockfile or package.json at repo root)" >&2; exit 1; fi

# Does a package.json script exist? node fallback so no jq dependency.
has_script() { node -e 'const s=(require("./package.json").scripts)||{};process.exit(s[process.argv[1]]?0:1)' "$1" 2>/dev/null; }
# Echo the first candidate script that exists.
pick() { for c in "$@"; do has_script "$c" && { echo "$c"; return 0; }; done; return 1; }

FAILED=()
run() { # label, command...
  local label="$1"; shift
  step "$label"
  if "$@"; then ok "$label"; else
    fail "$label"; FAILED+=("$label")
    [ "$FAST_FAIL" -eq 1 ] && exit 1
  fi
}
run_script() { # label, candidate scripts...
  local label="$1"; shift
  local s; s="$(pick "$@")" || { skip "$label"; return 0; }
  run "$label ($s)" "$PM" run "$s"
}

# install
if [ "$FROZEN" -eq 1 ]; then
  case "$PM" in
    npm) run "install" npm ci ;;
    bun|pnpm|yarn) run "install" "$PM" install --frozen-lockfile ;;
  esac
else
  run "install" "$PM" install
fi

run_script "build"     build
run_script "typecheck" typecheck check:ci compile tsc
run_script "test"      test:unit test
[ "$WITH_E2E" -eq 1 ] && run_script "e2e" test:e2e e2e
run_script "lint"      lint:all lint
run_script "format"    format:check fmt:check

if [ "${#FAILED[@]}" -eq 0 ]; then
  printf '\n\033[1;32mPASS - all validations green\033[0m\n'
else
  printf '\n\033[1;31mFAIL - %s\033[0m\n' "${FAILED[*]}" >&2
  exit 1
fi
