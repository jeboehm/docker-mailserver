#!/bin/sh
set -e

POPEYE_SCORE_THRESHOLD=76
CURRENT_SCORE=$(popeye -o score)

if [ "${CURRENT_SCORE}" -lt "${POPEYE_SCORE_THRESHOLD}" ]; then
	echo "Error: Popeye score is below ${POPEYE_SCORE_THRESHOLD}, current score: ${CURRENT_SCORE}"

	exit 1
fi

exit 0
