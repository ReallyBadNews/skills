#!/usr/bin/env bash
# Upload PR screenshots/GIFs to the repo's orphan `pr-assets` branch and print
# the base URL to embed them with. Run from inside the repo.
#
#   upload-pr-assets.sh <local-dir> <folder>     e.g. temp/pr-assets/ke-foo ke-foo
#   DRY_RUN=1 upload-pr-assets.sh ...            build the commit, skip the push
#
# The branch is append-only: each upload is a new commit on top of the last, so
# every SHA an older PR body links to stays reachable. Never force-push it.
# Embed as  ![alt](<base-url>/<file>?raw=true)  — private repos render these
# only for viewers signed in to GitHub with access to the repo.
set -euo pipefail

dir=${1:?usage: upload-pr-assets.sh <local-dir> <folder>}
folder=${2:?usage: upload-pr-assets.sh <local-dir> <folder>}
remote=${REMOTE:-origin}
branch=pr-assets

shopt -s nullglob
files=("$dir"/*.png "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.gif)
if [ ${#files[@]} -eq 0 ]; then
  echo "no .png/.jpg/.gif files in $dir" >&2
  exit 1
fi

parent=""
if git ls-remote --exit-code --heads "$remote" "$branch" >/dev/null 2>&1; then
  git fetch -q "$remote" "$branch"
  parent=$(git rev-parse FETCH_HEAD)
fi

index=$(mktemp)
trap 'rm -f "$index"' EXIT
export GIT_INDEX_FILE=$index
if [ -n "$parent" ]; then git read-tree "$parent"; else git read-tree --empty; fi
for f in "${files[@]}"; do
  blob=$(git hash-object -w "$f")
  git update-index --add --cacheinfo "100644,$blob,$folder/$(basename "$f")"
done
tree=$(git write-tree)
unset GIT_INDEX_FILE

if [ -n "$parent" ]; then
  commit=$(git commit-tree "$tree" -p "$parent" -m "chore: add $folder PR assets")
else
  commit=$(git commit-tree "$tree" -m "chore: add $folder PR assets")
fi

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
if [ -z "${DRY_RUN:-}" ]; then
  git push -q "$remote" "${commit}:refs/heads/${branch}"
fi
git ls-tree --name-only "$commit" "$folder/" >&2
echo "https://github.com/${repo}/blob/${commit}/${folder}"
