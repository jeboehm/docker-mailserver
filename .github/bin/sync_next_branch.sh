#!/bin/bash
# Keep the long-lived `next` branch current with `main`.
#
# `next` carries work for future versions that must not ship yet. Most of the
# time it holds no commits of its own and is fast-forwarded, which keeps its
# history linear; once it does carry work, `main` is merged into it. A conflict
# is handed to a human as a pull request instead of being swallowed.
#
# Requires a token that may push to `next` and open pull requests. It must not
# be GITHUB_TOKEN: pushes made with that token do not trigger workflows, so
# build.yml would never publish the `:next` images.
#
# Environment:
#   GH_TOKEN   token for the `gh` CLI (conflict path only)
set -euo pipefail

SOURCE_BRANCH="${SOURCE_BRANCH:-main}"
TARGET_BRANCH="${TARGET_BRANCH:-next}"

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'

# Fetch both branches explicitly rather than relying on the checkout to have
# left tracking refs behind. `merge-base` needs real history on both sides.
git fetch --no-tags --force origin \
	"refs/heads/${SOURCE_BRANCH}:refs/remotes/origin/${SOURCE_BRANCH}"

# Bootstrap: nothing to sync into yet, so branch off `main` and stop.
if ! git ls-remote --exit-code --heads origin "${TARGET_BRANCH}" >/dev/null; then
	echo "::notice::${TARGET_BRANCH} does not exist yet, creating it from ${SOURCE_BRANCH}"
	git push origin "refs/remotes/origin/${SOURCE_BRANCH}:refs/heads/${TARGET_BRANCH}"
	exit 0
fi

git fetch --no-tags --force origin \
	"refs/heads/${TARGET_BRANCH}:refs/remotes/origin/${TARGET_BRANCH}"

if git merge-base --is-ancestor "origin/${SOURCE_BRANCH}" "origin/${TARGET_BRANCH}"; then
	echo "::notice::${TARGET_BRANCH} already contains ${SOURCE_BRANCH}, nothing to do"
	exit 0
fi

# No commits of its own, so a fast-forward avoids a pointless merge commit.
if git merge-base --is-ancestor "origin/${TARGET_BRANCH}" "origin/${SOURCE_BRANCH}"; then
	echo "::notice::fast-forwarding ${TARGET_BRANCH} to ${SOURCE_BRANCH}"
	git push origin "refs/remotes/origin/${SOURCE_BRANCH}:refs/heads/${TARGET_BRANCH}"
	exit 0
fi

echo "::notice::${TARGET_BRANCH} has diverged, merging ${SOURCE_BRANCH} into it"
git checkout -B "${TARGET_BRANCH}" "origin/${TARGET_BRANCH}"

if git merge --no-ff --no-edit "origin/${SOURCE_BRANCH}"; then
	git push origin "${TARGET_BRANCH}"
	exit 0
fi

git merge --abort

if [ -z "$(gh pr list --base "${TARGET_BRANCH}" --head "${SOURCE_BRANCH}" --state open --json number --jq '.[].number')" ]; then
	gh pr create \
		--base "${TARGET_BRANCH}" \
		--head "${SOURCE_BRANCH}" \
		--title "chore: merge ${SOURCE_BRANCH} into ${TARGET_BRANCH}" \
		--body "The automatic sync could not merge \`${SOURCE_BRANCH}\` into \`${TARGET_BRANCH}\` because of a conflict. Resolve it here; the next push to \`${SOURCE_BRANCH}\` takes over again once this is merged."
fi

echo "::error::merge conflict between ${SOURCE_BRANCH} and ${TARGET_BRANCH}, resolve the pull request"
exit 1
