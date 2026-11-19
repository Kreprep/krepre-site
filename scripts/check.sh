#!/usr/bin/env bash
# Site-contract checker: bash scripts/check.sh <public-dir>
set -u
dir=${1:?usage: check.sh <public-dir>}
root=$(cd "$(dirname "$0")/.." && pwd)
fail() { echo "FAIL $1: $2"; exit 1; }

# -z makes each file one record, so tags split over lines still match.
rule() { # rule <message> <regex>
  local f
  while IFS= read -r -d '' f; do
    grep -qzEi -- "$2" "$f" && fail "$f" "$1"
  done < <(find "$dir" -name '*.html' -print0)
}
off='(https?:|//)'
rule "script element" '<script'
rule "style element or style attribute" '<style|<[^>]*[[:space:]]style='
rule "off-site src" "<[^>]*[[:space:]]src=[\"']?$off"
rule "off-site stylesheet/preload/icon" "<link[^>]*[[:space:]]rel=[\"']?(stylesheet|preload|icon)[^>]*[[:space:]]href=[\"']?$off"
rule "off-site stylesheet/preload/icon" "<link[^>]*[[:space:]]href=[\"']?$off[^>]*[[:space:]]rel=[\"']?(stylesheet|preload|icon)"

patterns=${LEAK_PATTERNS:-}
if [ -z "$patterns" ] && [ -f "$root/.leak-patterns" ]; then patterns=$(cat "$root/.leak-patterns"); fi
if [ -z "$(printf '%s' "$patterns" | tr -d '[:space:]')" ]; then
  [ -n "${CI:-}" ] && fail "leak patterns" "none configured in CI"
  echo "warning: no leak patterns configured, skipping that check"
else
  n=0
  while IFS= read -r p; do
    n=$((n + 1)); p=${p%$'\r'}
    case $p in ''|'#'*) continue ;; esac
    hits=$(grep -rIilE -e "$p" "$dir" 2>/dev/null)
    rc=$?
    [ $rc -le 1 ] || fail "leak patterns" "pattern on line $n is not a valid regex"
    [ -z "$hits" ] || fail "$(echo "$hits" | head -1)" "leak pattern on line $n matched"
  done <<< "$patterns"
fi
echo ok
