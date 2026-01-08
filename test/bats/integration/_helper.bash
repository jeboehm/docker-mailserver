#!/usr/bin/env bash

skip_in_kubernetes() {
	if [ "${IS_KUBERNETES}" -eq "1" ]; then
		skip "Skipping test in Kubernetes"
	fi
}

skip_in_non_kubernetes() {
	if [ "${IS_KUBERNETES}" -ne "1" ]; then
		skip "Skipping test in non-Kubernetes"
	fi
}

# Split a string by colon (:) character and return both parts
# Usage: split_by_colon "hostname:8080"
# Returns: Two lines - first part on line 1, second part on line 2
# Examples:
#   result=$(split_by_colon "localhost:8080")
#   part1=$(echo "$result" | head -n1)  # Gets "localhost"
#   part2=$(echo "$result" | tail -n1)  # Gets "8080"
#
#   # Alternative using read:
#   read -r part1 part2 < <(split_by_colon "hostname:8080")
#
#   # Using array:
#   parts=($(split_by_colon "hostname:8080"))
#   part1="${parts[0]}"
#   part2="${parts[1]}"
split_by_colon() {
	local input="$1"
	local part1="${input%%:*}"
	local part2="${input#*:}"
	echo "$part1"
	echo "$part2"
}
