#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

exec 9>.deploy.lock
flock -n 9 || exit 0

git fetch --quiet origin
# live holds only REVISION; the value ends up as a command argument, so insist on a bare commit id
target=$(git show origin/live:REVISION)
[[ $target =~ ^[0-9a-f]{40}$ ]] || { echo "origin/live:REVISION is not a commit id" >&2; exit 1; }
if [ -f .deployed ] && [ "$(cat .deployed)" = "$target" ]; then
	exit 0
fi

echo "deploying $target"
# merge --ff-only alone would accept local edits to files the update does not touch
git diff --quiet HEAD || { echo "working tree has local changes" >&2; exit 1; }
git merge --quiet --ff-only "$target"
echo "SITE_REVISION=$target" > .env
docker compose up -d --wait
echo "$target" > .deployed
# Each deploy leaves the previous tagged image behind on a small disk; a dangling-only prune would keep it
docker image prune -af > /dev/null
