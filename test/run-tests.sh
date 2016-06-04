#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd ${DIR}/tests

postfix start

for test in $(ls -1)
do
  ./${test}
done
