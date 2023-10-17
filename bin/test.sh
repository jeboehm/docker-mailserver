#!/bin/bash
# Helper script for docker compose.
# Usage: bin/production.sh [COMMAND]
# Example: bin/production.sh up -d
#
# You can also use docker compose directly, but this script
# will make sure that the correct compose files are used.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="docker comspose"

## Guard against empty $DIR
if [[ "$DIR" != */bin ]]; then
    echo "Could not detect working directory."
    exit 1
fi

$BIN version --short >/dev/null 2>&1 || {
    BIN=$(which docker-compose)
}

cd "${DIR}/../" || exit

docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  -f docker-compose.test.yml \
  "$@"
