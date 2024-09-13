#!/bin/bash
# Helper script for docker compose.
# Usage: bin/test.sh [COMMAND]
# Example: bin/test.sh up -d
#
# You can also use docker compose directly, but this script
# will make sure that the correct compose files are used.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="docker compose"

## Guard against empty $DIR
if [[ "$DIR" != */bin ]]; then
    echo "Could not detect working directory."
    exit 1
fi

$BIN version --short >/dev/null 2>&1 || {
    BIN=$(which docker-compose)

    if ! [ -x "${BIN}" ]; then
        echo "Could not find docker-compose."
        exit 1
    fi
}

cd "${DIR}/../" || exit

if [ ! -r docker-compose.yml ] || [ ! -r docker-compose.production.yml ] || [ ! -r docker-compose.test.yml ]
then
    echo "Could not find docker-compose.yml or docker-compose.production.yml or docker-compose.test.yml in ${PWD}."
    exit 1
fi

${BIN} \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  -f docker-compose.test.yml \
  "$@"
