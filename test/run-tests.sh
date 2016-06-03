#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd ${DIR}/tests

for test in $(ls -1)
do
  ./${test}
done
