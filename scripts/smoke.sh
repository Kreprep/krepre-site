#!/usr/bin/env bash
# Usage: smoke.sh <base-url>
set -euo pipefail
base=${1:?usage: smoke.sh <base-url>}
base=${base%/}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
# Sets $status and $headers (CR removed) and writes the body to $tmp/body.
get() {
	local p=$1; shift
	status=$(curl -sS -o "$tmp/body" -D "$tmp/h" -w '%{http_code}' "$@" "$base$p") || fail "$p: request failed"
	headers=$(tr -d '\r' < "$tmp/h")
}
has() { grep -qiE "$1" <<< "$headers"; }

for p in / /resume/ /homelab/ /writing/; do
	get "$p"
	[ "$status" = 200 ] || fail "$p returned $status, want 200"
	has '^content-type: text/html' || fail "$p is not text/html"
done

get /
has "^content-security-policy:.*default-src 'none'" || fail "/ lacks the Content-Security-Policy header"
has '^x-content-type-options: nosniff' || fail "/ lacks X-Content-Type-Options: nosniff"
has '^strict-transport-security:' || fail "/ lacks Strict-Transport-Security"
css=$(grep -oE '/css/[^"'"'"' >]+\.css' "$tmp/body" | head -n 1 || true)
[ -n "$css" ] || fail "/ links no stylesheet under /css/"

get "$css"
[ "$status" = 200 ] || fail "$css returned $status, want 200"
has '^cache-control:.*immutable' || fail "$css is not served immutable"

get /no-such-page/
[ "$status" = 404 ] || fail "missing page returned $status, want 404"
has "^content-security-policy:.*default-src 'none'" || fail "missing page lacks the Content-Security-Policy header"
grep -q 404 "$tmp/body" || fail "missing page does not show the site 404 page"

get /resume.pdf
[ "$status" = 200 ] || fail "/resume.pdf returned $status, want 200"
has '^content-type: application/pdf' || fail "/resume.pdf is not application/pdf"
has '^content-disposition:.*Eugene-Maniego-Resume\.pdf' || fail "/resume.pdf lacks the Content-Disposition file name"
! has '^content-security-policy:' || fail "/resume.pdf carries a Content-Security-Policy"

get / -H 'Accept-Encoding: gzip'
has '^content-encoding: gzip' || fail "/ is not gzip-compressed"

echo ok
