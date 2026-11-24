# How to Upgrade

1. Read the [Upgrade changelog](../reference/upgrade-changelog.md) for every version between yours and the target.
2. Compare `deploy/compose` and `deploy/kustomize` with your copies and apply changes to volumes and configuration.
3. Compare `.env` with `.env.dist` and add new or changed environment variables.
4. Pull new images (Docker) or update image tags (Kubernetes) and redeploy.
5. Carry out the steps the changelog lists for those versions.
