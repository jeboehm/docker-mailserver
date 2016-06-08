#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${DIR}/tests" || exit

postfix start

for test in *.sh
do
  if ! [ -e "${test}" ]; then break; fi
  "./${test}"
done
