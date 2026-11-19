#!/usr/bin/env bash
# Self-test for deploy.sh with a stub docker (and flock where the real one is missing).
set -euo pipefail
src=$(cd "$(dirname "$0")/.." && pwd)
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export LOG="$t/docker.log" FAIL="$t/docker.fail"
mkdir "$t/bin"
printf '#!/usr/bin/env bash\necho "$*" >> "$LOG"\n[ ! -e "$FAIL" ]\n' > "$t/bin/docker"
command -v flock > /dev/null || printf '#!/usr/bin/env bash\nexit 0\n' > "$t/bin/flock"
chmod +x "$t/bin"/*

git init -q --bare -b main "$t/origin.git"
git clone -q "$t/origin.git" "$t/seed" 2> /dev/null
git -C "$t/seed" checkout -q -B main
# Commits to main, then a parentless pointer commit on live, built as CI builds it.
point() {
	local blob tree
	blob=$(echo "$1" | git -C "$t/seed" hash-object -w --stdin)
	tree=$(printf '100644 blob %s\tREVISION\n' "$blob" | git -C "$t/seed" mktree)
	git -C "$t/seed" push -q --force origin "$(git -C "$t/seed" commit-tree "$tree" -m live):refs/heads/live"
}
push() {
	echo "$1" > "$t/seed/f"; git -C "$t/seed" add f; git -C "$t/seed" commit -qm "$1"
	git -C "$t/seed" push -q origin main; point "$(git -C "$t/seed" rev-parse HEAD)"
}
push one
git clone -q "$t/origin.git" "$t/site"
cp "$src/deploy.sh" "$t/site/"

run() { (cd "$t/site" && PATH="$t/bin:$PATH" ./deploy.sh > /dev/null 2>&1); }
deployed() { cat "$t/site/.deployed"; }
head_of() { git -C "$t/origin.git" rev-parse main; }

run || { echo "FAIL first run"; exit 1; }
[ -s "$LOG" ] || { echo "FAIL first run did not call docker"; exit 1; }
[ "$(deployed)" = "$(head_of)" ] || { echo "FAIL .deployed after first run"; exit 1; }
[ "$(cat "$t/site/.env")" = "SITE_REVISION=$(head_of)" ] || { echo "FAIL .env after first run"; exit 1; }

: > "$LOG"
run || { echo "FAIL idle run"; exit 1; }
[ ! -s "$LOG" ] || { echo "FAIL idle run called docker"; exit 1; }

push two
run || { echo "FAIL run after new commit"; exit 1; }
[ -s "$LOG" ] && [ "$(deployed)" = "$(head_of)" ] || { echo "FAIL redeploy"; exit 1; }
[ "$(cat "$t/site/.env")" = "SITE_REVISION=$(head_of)" ] || { echo "FAIL .env after redeploy"; exit 1; }

old=$(deployed)
push three
touch "$FAIL"
if run; then echo "FAIL docker failure exited 0"; exit 1; fi
[ "$(deployed)" = "$old" ] || { echo "FAIL .deployed changed after docker failure"; exit 1; }
rm "$FAIL"

# local commit on top of a checkout that origin has moved past
echo local > "$t/site/g"; git -C "$t/site" add g; git -C "$t/site" commit -qm local
push four
: > "$LOG"
if run; then echo "FAIL diverged history exited 0"; exit 1; fi
[ ! -s "$LOG" ] || { echo "FAIL diverged history called docker"; exit 1; }

point not-a-commit
: > "$LOG"
if run; then echo "FAIL bad REVISION exited 0"; exit 1; fi
[ ! -s "$LOG" ] || { echo "FAIL bad REVISION called docker"; exit 1; }

echo ok
