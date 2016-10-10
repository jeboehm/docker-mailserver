#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

## Guard against empty $DIR
if [[ "$DIR" != */.travis ]]; then
    echo "Could not detect working directory."
    exit 1
fi

cd "${DIR}/../" || exit

PROD="./bin/production.sh"
TEST="./bin/test.sh"

$TEST build
$PROD up -d
sleep 60
$TEST run --rm test /opt/tests/run-tests.sh
$PROD logs

$TEST down -v
