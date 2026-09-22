#!/bin/sh
# Splits .env into the inputs of the root kustomization.yaml: credentials go
# into config/kubernetes/secret.env (Secret secret-config-env), everything
# else into config/kubernetes/config.env (ConfigMap config-env). Kustomize
# cannot pick keys from an env file, hence the split by key name: every key
# containing PASSWORD, PASSWD or _KEY counts as a credential.
# Usage: bin/kubernetes-env.sh [env file, default .env]
set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${1:-${DIR}/.env}"
TARGET_DIRECTORY="${DIR}/config/kubernetes"
SECRET_KEYS='^[A-Z0-9_]*(PASSWORD|PASSWD|_KEY)[A-Z0-9_]*='

if ! [ -r "$ENV_FILE" ]; then
	echo "Could not read ${ENV_FILE}. Copy .env.dist to .env and adjust it first."
	exit 1
fi

mkdir -p "$TARGET_DIRECTORY"
grep -Ev "$SECRET_KEYS" "$ENV_FILE" >"${TARGET_DIRECTORY}/config.env" || true
grep -E "$SECRET_KEYS" "$ENV_FILE" >"${TARGET_DIRECTORY}/secret.env" || true
