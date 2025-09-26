#!/bin/sh
set -e

# Find all files that contain pod definitions
POD_FILES=$(find ../../deploy/kustomize/ -type f \( -iname '*statefulset*' -o -iname '*deployment*' -o -iname '*cronjob*' -o -iname '*job*' -o -iname '*daemonset*' \))

echo "$POD_FILES" | while read -r file; do
	echo "Validating $file"
	node_modules/.bin/pajv -s schema/security-context-schema.json -d "$file"
done

exit 0
