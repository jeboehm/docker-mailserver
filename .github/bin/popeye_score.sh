#!/bin/sh
set -e

score=$(popeye -o score)

if [ "$score" -lt 90 ]; then
  echo "Popeye score is below 90"

  exit 1
fi

exit 0
