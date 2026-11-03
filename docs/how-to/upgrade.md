# How to Upgrade

When upgrading docker-mailserver:

1. Review [Upgrade changelog](../reference/upgrade-changelog.md) for your target version.
2. Update deployment manifests in `deploy/compose` and `deploy/kustomize` for any volume or configuration changes.
3. Update `.env` for new or changed environment variables.
4. Pull new images (Docker) or update image tags (Kubernetes) and redeploy.
5. Run any version-specific steps from the changelog (e.g. changing `DOVEADM_API_KEY` for v7.3).

For version-by-version notes, see [Upgrade changelog](../reference/upgrade-changelog.md).
