#!/bin/bash
# Build the .env for a test case by layering .github/test-matrix/<case>.env on
# top of the defaults, keeping the last definition of every key.
set -euo pipefail

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <test-case>" >&2
	exit 1
fi

TEST_CASE="$1"
OVERRIDES=".github/test-matrix/${TEST_CASE}.env"

if [ ! -f "${OVERRIDES}" ]; then
	echo "Unknown test case: ${TEST_CASE} (${OVERRIDES} not found)" >&2
	exit 1
fi

make .env
cat .env "${OVERRIDES}" >.env.tmp
awk -F= '{seen[$1]=$0} END {for (key in seen) print seen[key]}' .env.tmp >.env
rm .env.tmp
