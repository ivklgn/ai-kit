#!/bin/sh
# Resolve the audit scope and print a compact inventory.
#
# Usage:
#   resolve_scope.sh                  # scope = current git changes vs merge base
#   resolve_scope.sh path [path...]   # scope = those paths (git changes inside them if any)
#   resolve_scope.sh --base REF [path...]
#
# Output sections: BASE, MODE, CHANGED, MANIFESTS, DIRS.
# Every line is `key<TAB>value` or a plain path — parse, do not re-derive.

set -eu

base=""
paths=""

while [ $# -gt 0 ]; do
  case "$1" in
    --base)
      [ $# -ge 2 ] || { echo "resolve_scope.sh: --base needs a ref" >&2; exit 2; }
      base="$2"
      shift 2
      ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      paths="$paths $1"
      shift
      ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || { echo "resolve_scope.sh: not a git repository" >&2; exit 1; }
root=$(git rev-parse --show-toplevel)
cd "$root"

# --- Resolve the baseline ref -------------------------------------------------
if [ -z "$base" ]; then
  default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  if [ -z "$default" ]; then
    for candidate in origin/main origin/master main master; do
      if git rev-parse --verify --quiet "$candidate" >/dev/null 2>&1; then
        default="$candidate"
        break
      fi
    done
  fi
  if [ -n "$default" ]; then
    base=$(git merge-base HEAD "$default" 2>/dev/null || echo "$default")
  else
    base="HEAD"
  fi
fi

# --- Collect changed files ----------------------------------------------------
# Committed since base, staged, unstaged, and untracked — deduplicated.
changed=$(
  {
    git diff --name-only "$base" 2>/dev/null || true
    git diff --name-only 2>/dev/null || true
    git diff --cached --name-only 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | sed '/^$/d' | sort -u
)

# --- Apply path filter, or fall back to the paths themselves ------------------
mode="git-changes"
if [ -n "$paths" ]; then
  filtered=""
  for p in $paths; do
    p=${p#./}
    p=${p%/}
    hit=$(printf '%s\n' "$changed" | grep -E "^${p}(/|$)" || true)
    filtered=$(printf '%s\n%s\n' "$filtered" "$hit" | sed '/^$/d')
  done
  filtered=$(printf '%s\n' "$filtered" | sort -u | sed '/^$/d')

  if [ -n "$filtered" ]; then
    mode="path-scoped-changes"
    changed="$filtered"
  else
    # No changes inside the given paths: audit them as-is against their consumers.
    mode="path-snapshot"
    changed=$(
      for p in $paths; do
        git ls-files -- "$p" 2>/dev/null || true
      done | sed '/^$/d' | sort -u
    )
  fi
fi

count=$(printf '%s\n' "$changed" | sed '/^$/d' | wc -l | tr -d ' ')

printf 'BASE\t%s\n' "$base"
printf 'MODE\t%s\n' "$mode"
printf 'COUNT\t%s\n' "$count"

if [ "$count" = "0" ]; then
  printf '\nCHANGED\t(none — ask the user what to audit)\n'
  exit 0
fi

printf '\nCHANGED\n'
printf '%s\n' "$changed"

# --- Ecosystem manifests governing the scope ----------------------------------
# Only manifests in a directory that is an ancestor of a changed file: these are
# the ones that actually govern it. Signals which surface-detection rules apply
# (see references/surface-map.md).
printf '\nMANIFESTS\n'
manifest_re='(package\.json|go\.mod|Cargo\.toml|pyproject\.toml|setup\.py|pom\.xml|build\.gradle(\.kts)?|Gemfile|composer\.json|deno\.json|pubspec\.yaml|Package\.swift|Dockerfile|docker-compose\.ya?ml|Chart\.yaml|serverless\.ya?ml|schema\.graphql|openapi\.(ya?ml|json)|[^/]*\.(csproj|proto|tf))'
all_manifests=$(git ls-files 2>/dev/null | grep -E "(^|/)${manifest_re}$" || true)

ancestors=$(
  printf '%s\n' "$changed" | while IFS= read -r f; do
    [ -n "$f" ] || continue
    d=$(dirname "$f")
    while :; do
      [ "$d" = "." ] && printf '\n' && break
      printf '%s/\n' "$d"
      d=$(dirname "$d")
    done
  done | sort -u
)

manifests=$(
  printf '%s\n' "$all_manifests" | while IFS= read -r m; do
    [ -n "$m" ] || continue
    md=$(dirname "$m")
    if [ "$md" = "." ]; then
      printf '%s\n' "$m"
    elif printf '%s\n' "$ancestors" | grep -qxF "$md/"; then
      printf '%s\n' "$m"
    fi
  done | sort -u
)

if [ -n "$manifests" ]; then
  printf '%s\n' "$manifests" | head -25
else
  printf '(none — surface is not declared by a package manifest; derive it from the code)\n'
fi

# --- Top-level directories touched -------------------------------------------
printf '\nDIRS\n'
printf '%s\n' "$changed" | awk -F/ 'NF>1{print $1"/"$2} NF==1{print "(root)"}' | sort | uniq -c | sort -rn | head -20
