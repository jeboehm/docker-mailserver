#!/bin/sh
set -e

SCHEMA=schema/security-context-schema.json

# Find all files that contain pod definitions
POD_FILES=$(find ../../deploy/kustomize/ -type f \( -iname '*statefulset*' -o -iname '*deployment*' -o -iname '*cronjob*' -o -iname '*job*' -o -iname '*daemonset*' \))

if [ -z "$POD_FILES" ]; then
	echo "No pod manifests found below deploy/kustomize/" >&2
	exit 1
fi

echo "$POD_FILES" | while read -r file; do
	echo "Validating $file"
	node_modules/.bin/jsonschema validate "$SCHEMA" "$file"
done
