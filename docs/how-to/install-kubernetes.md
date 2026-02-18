# How to Install on Kubernetes

This guide describes how to deploy docker-mailserver on Kubernetes with Kustomize. An external MySQL-compatible database is required; the kustomization does not provision a database.

A full example is in [example-configs/kustomize/external-db-and-https-ingress](https://github.com/jeboehm/docker-mailserver/tree/main/docs/example-configs/kustomize/external-db-and-https-ingress).

## Prerequisites

- Kubernetes cluster with kubectl configured
- MySQL or Percona XtraDB (or compatible) database
- Domain and DNS (for ingress)

## Steps

### 1. Configure environment (ConfigMap and Secrets)

Use `.env.dist` as a reference for the required variables. Create a Kubernetes ConfigMap from the non-sensitive values and Kubernetes Secrets for sensitive values (database credentials, passwords, API keys). See [Environment variables reference](../reference/environment-variables.md) for the full variable list.

The example configuration in [example-configs/kustomize/external-db-and-https-ingress](../example-configs/kustomize/external-db-and-https-ingress/) shows how to structure these resources.

### 2. Create namespace

```bash
kubectl create namespace mail
```

### 3. Generate TLS certificates (if not using cert-manager)

```bash
bin/create-tls-certs.sh
```

This writes a self-signed certificate and key to `config/tls/tls.crt` and `config/tls/tls.key`. For production, use certificates from a CA (e.g. cert-manager with Let's Encrypt) instead.

### 4. Create TLS secret

```bash
kubectl create -n mail secret tls tls-certs \
  --cert=config/tls/tls.crt \
  --key=config/tls/tls.key
```

### 5. Apply Kustomize manifests

From the project root:

```bash
kubectl apply -n mail -k .
```

### 6. Verify pods

```bash
kubectl get pods -n mail
```

Wait until all pods are running and healthy.

### 7. Run setup wizard

```bash
kubectl exec -n mail -it deployment/web -c php-fpm -- setup.sh
```

Use the wizard to set initial configuration, create the first email address, and create an admin user.

### 8. Access the management interface

Use your configured ingress and the admin credentials from the wizard.

## Post-installation

- Configure DNS and TLS as for Docker. See [How to configure DNS](configure-dns.md) and [How to configure TLS certificates](configure-tls.md).
- Change `DOVEADM_API_KEY` from default if using observability (v7.3+).

## Troubleshooting

- **Pods not starting:** Check pod logs with `kubectl logs -n mail <pod-name>` and events with `kubectl describe pod -n mail <pod-name>`.
- **Database errors:** Verify database connectivity and that the `MYSQL_*` variables in the ConfigMap/Secrets are correct.
- **TLS errors:** Confirm the `tls-certs` secret exists in the `mail` namespace and the certificate paths are correct.
- **Setup wizard fails:** Ensure the web pod is running (`kubectl get pods -n mail`) before running the exec command.
