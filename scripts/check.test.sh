#!/usr/bin/env bash
# Self-test for check.sh
set -u
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
# copy so the repo-root .leak-patterns file is not picked up
mkdir "$tmp/scripts"; cp "$(dirname "$0")/check.sh" "$tmp/scripts/"; chk=$tmp/scripts/check.sh
export LEAK_PATTERNS='secret-[0-9]+'
unset CI

page() { rm -rf "$tmp/p"; mkdir "$tmp/p"; printf '<!doctype html><title>t</title>%s' "$1" > "$tmp/p/index.html"; }
run() { out=$(bash "$chk" "$tmp/p" 2>&1); rc=$?; }
passes() { page "$2"; run; [ $rc -eq 0 ] || { echo "FAIL $1 should pass: $out"; exit 1; }; }
fails() { page "$2"; run; [ $rc -ne 0 ] || { echo "FAIL $1 should fail"; exit 1; }; }

passes clean '<p>hello</p>'
fails script '<script>1</script>'
passes escaped-code '<pre>&lt;p style=x&gt; &lt;img src=https://a.b/c&gt;</pre>'
passes prose '<p>use style= and src=https://x.y here</p>'
fails style-attr '<p style=color:red>x</p>'
fails offsite-img '<img src=https://example.com/a.png>'
fails offsite-css '<link rel=stylesheet href=https://example.com/a.css>'
passes offsite-anchor '<a href=https://example.com>x</a>'
fails leak '<p>secret-42</p>'
case $out in *secret*) echo "FAIL pattern text leaked in output"; exit 1 ;; esac

unset LEAK_PATTERNS
page '<p>hello</p>'
CI=true run; [ $rc -ne 0 ] || { echo "FAIL CI without patterns should fail"; exit 1; }
unset CI
run; [ $rc -eq 0 ] || { echo "FAIL no CI without patterns should pass: $out"; exit 1; }
echo ok
