#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

## Guard against empty $DIR
if [[ "$DIR" != */bin ]]; then
    echo "Could not detect working directory."
    exit 1
fi

cd "${DIR}/../" || exit

docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  -f docker-compose.test.yml \
  "$@"
