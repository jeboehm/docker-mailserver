#!/bin/sh

SA_DIR="/var/run/secrets/kubernetes.io/serviceaccount"
APISERVER="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
TOKEN="$(cat ${SA_DIR}/token)"
CACERT="${SA_DIR}/ca.crt"
NAMESPACE="$(cat ${SA_DIR}/namespace)"

cat >/tmp/kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: ${CACERT}
    server: ${APISERVER}
  name: in-cluster
contexts:
- context:
    cluster: in-cluster
    namespace: ${NAMESPACE}
    user: sa
  name: sa@in-cluster
current-context: sa@in-cluster
users:
- name: sa
  user:
    token: ${TOKEN}
EOF
