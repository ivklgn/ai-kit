#!/usr/bin/env bash
# worktree.sh — isolation + affected-case detection for the test-health-check skill.
#
# The skill temporarily inserts fault probes into PRODUCTION code. Running that
# inside a throwaway git worktree guarantees the real working tree is never
# touched, even if probing is interrupted. Always run `cleanup` when done.
#
# Usage:
#   worktree.sh affected [base]   List files changed vs <base> (default: main) + uncommitted/untracked.
#   worktree.sh tests    [base]   Affected files filtered to likely test files.
#   worktree.sh setup             Create an isolated worktree from HEAD (with uncommitted+untracked
#                                 changes replayed); prints the worktree path on stdout.
#   worktree.sh cleanup <path>    Remove a worktree created by `setup`, then prune.
#   worktree.sh help              Show this help.
set -euo pipefail

# Heuristic for "looks like a test file" across common ecosystems. The skill
# refines source->test mapping semantically; this is only a first pass.
TEST_PATTERNS='(_test\.|\.test\.|\.spec\.|_spec\.|(^|/)test_|Test[s]?\.(java|kt|cs|scala)$|(^|/)(tests?|__tests__|spec|specs)/)'

die() { printf 'worktree.sh: %s\n' "$1" >&2; exit 1; }

require_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not inside a git repository"
}

# Union of: branch changes vs base (merge-base), unstaged, staged, untracked.
changed_files() {
  local base="${1:-main}" mb=""
  mb="$(git merge-base HEAD "$base" 2>/dev/null || true)"
  {
    [ -n "$mb" ] && git diff --name-only "$mb"...HEAD
    git diff --name-only
    git diff --name-only --cached
    git ls-files --others --exclude-standard
  } 2>/dev/null | sed '/^$/d' | sort -u
}

cmd_affected() { require_repo; changed_files "${1:-main}"; }

cmd_tests() {
  require_repo
  changed_files "${1:-main}" | grep -E "$TEST_PATTERNS" || true
}

cmd_setup() {
  require_repo
  local wt
  wt="$(mktemp -d "${TMPDIR:-/tmp}/thc-worktree.XXXXXX")"
  rmdir "$wt"   # `git worktree add` requires a non-existent path
  git worktree add --quiet --detach "$wt" HEAD
  # Replay uncommitted tracked changes so probes run against the in-progress code.
  if ! git diff HEAD --quiet 2>/dev/null; then
    git diff HEAD | git -C "$wt" apply --whitespace=nowarn - \
      || die "failed to replay uncommitted changes into worktree"
  fi
  # Replay untracked, non-ignored files.
  git ls-files --others --exclude-standard | while IFS= read -r f; do
    [ -n "$f" ] || continue
    mkdir -p "$wt/$(dirname "$f")"
    cp "$f" "$wt/$f"
  done
  printf '%s\n' "$wt"
}

cmd_cleanup() {
  require_repo
  local path="${1:-}"
  [ -n "$path" ] || die "cleanup requires a worktree path"
  git worktree remove --force "$path" 2>/dev/null || rm -rf "$path"
  git worktree prune >/dev/null 2>&1 || true
}

usage() {
  cat <<'EOF'
worktree.sh — isolation + affected-case detection for the test-health-check skill.

Usage:
  worktree.sh affected [base]   List files changed vs <base> (default: main) + uncommitted/untracked.
  worktree.sh tests    [base]   Affected files filtered to likely test files.
  worktree.sh setup             Create an isolated worktree from HEAD (changes replayed); prints path.
  worktree.sh cleanup <path>    Remove a worktree created by setup, then prune.
  worktree.sh help              Show this help.
EOF
}

main() {
  local sub="${1:-help}"
  shift || true
  case "$sub" in
    affected) cmd_affected "$@" ;;
    tests)    cmd_tests "$@" ;;
    setup)    cmd_setup "$@" ;;
    cleanup)  cmd_cleanup "$@" ;;
    help|-h|--help) usage ;;
    *) die "unknown subcommand: $sub (try: help)" ;;
  esac
}

main "$@"
