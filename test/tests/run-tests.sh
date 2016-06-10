#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${DIR}" || exit

postfix start

bats *.bats
