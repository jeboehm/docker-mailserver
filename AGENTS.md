# Agent instructions for docker-mailserver

This file gives AI agents and contributors the conventions they need to work on the codebase: services, repository layout,
configuration conventions, build and test workflow, CI and Git conventions. Documentation work (everything under `docs/`)
has its own guide in [`docs/AGENTS.md`](docs/AGENTS.md).

## Services

`docker-mailserver` runs one container (Docker Compose) or pod (Kubernetes) per service. Images built from this repository
live under `target/<service>/`; the remaining services use upstream images.

| Service     | Software                                                | Compose                         | Kustomize                                              | Internal address                                                |
| ----------- | ------------------------------------------------------- | ------------------------------- | ------------------------------------------------------ | --------------------------------------------------------------- |
| `mta`       | Postfix                                                 | `deploy/compose/mta.yaml`       | `deploy/kustomize/mta/` (StatefulSet)                  | `mta:25` (SMTP), `mta:587` (submission)                         |
| `mda`       | Dovecot                                                 | `deploy/compose/mda.yaml`       | `deploy/kustomize/mda/` (StatefulSet)                  | IMAP/POP3 (see below), LMTP `mda:2003`, doveadm HTTP `mda:8080` |
| `filter`    | Rspamd                                                  | `deploy/compose/filter.yaml`    | `deploy/kustomize/filter/` (StatefulSet)               | `filter:11332` (milter), `filter:11334` (controller / web UI)   |
| `web`       | FrankenPHP with mailserver-admin and Roundcube          | `deploy/compose/web.yaml`       | `deploy/kustomize/web/` (Deployment)                   | `web:8080` in Compose (published as 81), `web:80` in Kubernetes |
| `unbound`   | Unbound, DNSSEC-validating recursive resolver           | `deploy/compose/unbound.yaml`   | `deploy/kustomize/unbound/` (Deployment)               | `unbound:5353` in Compose, `unbound:53` in Kubernetes           |
| `ssl`       | Self-signed certificate generator                       | `deploy/compose/ssl.yaml`       | — (`make kubernetes-tls` creates `tls-certs`)          | —                                                               |
| `db`        | MySQL (`mysql:lts`) or PostgreSQL (`DB_IMAGE`)          | `deploy/compose/db.yaml`        | — (bring your own; `test/k8s/{mysql,pgsql}/` ship one) | `db:3306` / `db:5432`                                           |
| `redis`     | Redis (upstream image)                                  | `deploy/compose/redis.yaml`     | `deploy/kustomize/redis/` (StatefulSet)                | `redis:6379`                                                    |
| `fetchmail` | [fetchmailmgr](https://github.com/jeboehm/fetchmailmgr) | `deploy/compose/fetchmail.yaml` | `deploy/kustomize/fetchmail/` (Deployment)             | —                                                               |

Dovecot listens on `31143`/`31993`/`31110`/`31995` (IMAP/IMAPS/POP3/POP3S) in Compose, published as 143/993/110/995 by
`docker-compose.production.yml`, and on the standard ports in Kubernetes. It also serves auth on `2004` and ManageSieve on
`4190`. `web` runs FrankenPHP serving mailserver-admin (`/opt/admin`) and Roundcube (`/opt/roundcube`).

Mail flow: SMTP (25) or submission (587) on `mta` → Rspamd milter (`filter:11332`) → LMTP to `mda` → Maildir under
`/srv/vmail/<domain>/<user>/Maildir` (volume `data-mail`). Domains, users, aliases and the DKIM configuration live in the
database, whose schema is owned by mailserver-admin; Postfix and Dovecot query the `mail_domains`, `mail_users` and
`mail_aliases` tables directly. Rspamd keeps all of its state (Bayes, fuzzy, DKIM keys) in Redis and never touches the
database.

mailserver-admin is a separate project ([jeboehm/mailserver-admin](https://github.com/jeboehm/mailserver-admin));
`target/web/Dockerfile` downloads a release tarball (`ADMIN_VER`). Its console (`/opt/admin/bin/console`) is the CLI for
domains, users, aliases, DKIM and fetchmail accounts.

## Repository layout

- `target/<service>/` — Dockerfile plus a `rootfs/` overlay that is copied to `/` of the image.
- `deploy/compose/` — one Compose file per service, included by `docker-compose.yml`. `docker-compose.production.yml`
  publishes the host ports, `docker-compose.test.yml` adds mailpit and the test runner. A git-ignored
  `docker-compose.override.yml` is picked up by `bin/production.sh` when present.
- `deploy/kustomize/` — one directory per service plus `common/` (ConfigMap `config-service-map` with the internal
  addresses) and `ingress/traefik/`. The root `kustomization.yaml` generates the `config-env` ConfigMap from `.env`.
- `bin/` — `production.sh` and `test.sh` (Compose wrappers, see below) and `create-tls-certs.sh`.
- `test/bats/` — test runner image and BATS integration tests; `test/k8s/` — Kubernetes test overlay and test job;
  `test/pajv/` — JSON schema check of the pod security contexts; `test/super-linter/` — lint runner.
- `docs/` — MkDocs documentation, configured by `.mkdocs.yaml` in the root. See `docs/AGENTS.md`.
- `.github/` — workflows, helper scripts (`bin/`), composite actions, linter configuration (`linters/`), CI test matrix
  (`test-matrix/*.env`) and the list of third-party test images (`images.txt`).
- `.env.dist` — canonical list of user-facing environment variables; `make .env` copies it to the git-ignored `.env`.
- `config/` — git-ignored; `config/tls/` holds the certificates created by `bin/create-tls-certs.sh` for Kubernetes.

## Deployment parity

Compose and Kustomize must offer the same capabilities. When changing environment variables, volumes, ports or services
in `deploy/compose/`, apply the same logical change in `deploy/kustomize/` (and vice versa). Internal addresses differ on
purpose: Compose uses the container ports directly, Kubernetes Services publish the standard ports and
`deploy/kustomize/common/configmap.yaml` overrides the `*_ADDRESS` variables accordingly. New user-facing variables go
into `.env.dist` and `docs/reference/environment-variables.md`. Third-party images used by the tests are listed in
`.github/images.txt`; keep it in sync with `deploy/compose/*.yaml` and `test/k8s/`.

## Configuration conventions

- Services find each other through `<SERVICE>_<PROTOCOL>_ADDRESS=host:port` variables (e.g. `MTA_SMTP_SUBMISSION_ADDRESS`,
  `FILTER_MILTER_ADDRESS`, `UNBOUND_DNS_ADDRESS`). The Compose defaults are baked into the Dockerfiles; Kubernetes
  overrides them through `config-service-map`.
- Database access uses `DB_DRIVER`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_SERVER_VERSION` (plus
  `DB_IMAGE`, `DB_DATA_DIR`, `DB_TLS_VERIFY_CERT`). Compose accepts the former `MYSQL_*` names as a fallback, Kubernetes
  does not.
- Rspamd reads environment variables in its UCL configuration as `{= env.NAME =}`, which resolves to the process variable
  `RSPAMD_NAME`. `target/filter/rootfs/entrypoint.sh` exports `REDIS_*` and the encrypted controller password under that
  prefix; `RSPAMD_DNS_SERVERS` (Dockerfile, Kubernetes ConfigMap) is templated into `override.d/options.inc`.
- Postfix is configured with `postconf` in `target/mta/Dockerfile`; settings that depend on the environment (`RELAYHOST`,
  milter address, PROXY protocol) are applied at start by `target/mta/rootfs/usr/local/lib/init.sh`.
- Entrypoints share one shape: `[ "$#" -gt 0 ] && exec "$@"` (a command override or `docker exec` bypasses the daemon),
  an optional `/.banner.sh` generated in CI, then `exec` of the daemon.
- Images run as non-root with fixed IDs (Rspamd 11333, Dovecot/vmail 1000, web 1000, Unbound 100) on a read-only root
  filesystem with `tmpfs`/`emptyDir` for writable paths. Each image ships `/usr/local/bin/healthcheck.sh`;
  `070_docker.bats` fails when any container is unhealthy.
- Base images are pinned by digest. Versions of downloaded artifacts are declared as `ARG X_VER=... # renovate:
depName=...` so Renovate can bump them.

## Build, run, test

| Target                                | Effect                                                                                                         |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `make build`                          | Builds all images (`bin/test.sh build`).                                                                       |
| `make up`                             | `bin/production.sh up -d`; does not wait for the services to become healthy.                                   |
| `make fixtures`                       | Runs `test/fixtures.sh` in the `web` container (domains, users, aliases, DKIM, fetchmail account); rerunnable. |
| `make test`                           | `up` + `fixtures` + `bin/test.sh run --build --rm test` (full BATS suite).                                     |
| `make clean`                          | Stops everything and removes the project volumes (local data is lost).                                         |
| `make logs`                           | Dumps the logs of all services.                                                                                |
| `make lint`                           | Runs super-linter (see below).                                                                                 |
| `make docs-build` / `make docs-serve` | MkDocs strict build / live preview.                                                                            |
| `make kubernetes-*`, `make kind-load` | Kubernetes test flow: kind cluster, Traefik chart, Kustomize overlay under `test/k8s/`, test job.              |

`bin/production.sh` stacks `docker-compose.yml` + `docker-compose.production.yml` + `docker-compose.override.yml` (if
present); `bin/test.sh` stacks `docker-compose.yml` + `docker-compose.production.yml` + `docker-compose.test.yml`. Both
pass their arguments to `docker compose` (`bin/test.sh logs -f filter`, `bin/test.sh exec filter sh`).

## Integration tests

- Runner image `test/bats/Dockerfile` (Alpine): bats with bats-assert/bats-support, `swaks`, `dig`, `curl`, `jq`,
  `openssl`, `redis-cli`, `mariadb` and `psql` clients, the `docker` and `kubectl` CLIs, `php` with imap-tester.
  `test/bats/rootfs/entrypoint.sh` waits for the services (`wait-for-services.sh`) and then runs bats with
  `--timing`, `--print-output-on-failure` and a JUnit report in `/app/report` (bind-mounted to the git-ignored
  `test/report/`).
- Tests live in `test/bats/integration/NNN_<topic>.bats` and run in numeric order. Every test is self-contained: it
  sends its own mail with a body from `mail_needle` (unique per test and bats run, so mails left in the persistent
  Maildir by earlier runs never match) and polls for the outcome instead of sleeping. Only loose ordering remains
  (`060_mda.bats` counts the mails that `040_mta.bats` delivered).
- `_helper.bash` is loaded with `load '_helper'` in `setup()`; it loads bats-support and bats-assert itself, so use
  `assert_success`, `assert_failure [status]` and `assert_output` rather than `[ "$status" -eq 0 ]`. It provides
  skips (`skip_in_kubernetes`, `skip_in_non_kubernetes`, `skip_without_relayhost`), service access that works on
  both platforms (`exec_in_service`, `service_logs`, `service_log_count`, `service_logs_contain`; Kubernetes
  container names differ from the service names, see `kubernetes_container`), polling (`wait_for`, `wait_for_log`,
  `wait_for_mail`, which prints the file it found), mail inspection (`mail_needle`, `maildir`, `find_mail`,
  `mail_header` for unfolded header values), mailbox state through doveadm in `mda` (`mailbox_reset`,
  `quota_percentage`) and clients (`send_mail` wraps `swaks` and retries when Postfix's connection rate limit of 20
  per minute and client answers `421`, `db_query` prints rows only, `redis_cli`, `dns_query`
  against unbound, `imap_tester`, `tls_connect`, `tls_fingerprint`). Each function documents its arguments in a
  comment. `swaks --server host:port` takes the `*_ADDRESS` variables as they are.
- Put new checks into the topic file, not into a platform file: `070_docker.bats` only holds what needs the Docker
  CLI, everything else runs on both platforms through the helpers.
- Environment inside the runner: the `*_ADDRESS` variables from the Dockerfile (Compose defaults) or from
  `config-service-map` (Kubernetes), everything from `.env`, and `IS_KUBERNETES=1` on Kubernetes. Delivered mail is
  mounted read-only at `/srv/vmail`, the TLS certificates at `/media/tls`, and on Compose the Docker socket at
  `/var/run/docker.sock`. `exec_in_service`/`service_logs` find Compose containers through their Compose labels (the
  project name is read from the runner's own container; `COMPOSE_PROJECT_NAME` overrides it), so renamed checkouts
  and `docker compose -p` work.
- Fixtures: `test/fixtures.sh`, run by `make fixtures` inside the `web` container and by the `load-fixtures` init
  container of `test/k8s/test-job.yaml` (mounted from the `test-fixtures` ConfigMap that
  `test/k8s/base/kustomization.yaml` generates). It is rerunnable (exits early when `example.com` exists) and takes
  the fetchmail source address from `FIXTURES_MDA_IMAP_ADDRESS`. It creates domains `example.com` and `example.org`;
  `admin@example.com`/`changeme` (admin), `sendonly@example.com` (send-only), `quota@example.com` (1 MB quota),
  `disabled@example.com`, `disabledsendonly@example.com`, `fetchmailsource@example.org`, `fetchmailreceiver@example.org`
  (all `test1234`); aliases `foo@example.com`, `foo@example.org` and a catch-all for `example.com` pointing to admin;
  DKIM enabled for `example.com` with selector `dkim`.
- `./test/bats/integration` is bind-mounted into the runner, so test changes need no image rebuild. Run a single file
  with `bin/test.sh run --rm test bats 090_dkim.bats`.
- mailpit (`mailpit:1025`, API on `mailpit:8025`) only receives mail in the `relayhost` matrix case
  (`RELAYHOST=[mailpit]:1025`); in all other cases inspect the Maildir under `/srv/vmail`.

## CI

`.github/workflows/build.yml` builds all images including the test runner, then runs the Docker matrix (`default`,
`relayhost`, `postgres`) with `make up`, `make fixtures` and `bin/test.sh run --rm test`, and the Kubernetes matrix
(`default`, `relayhost`, `proxy`, `postgres`) on kind with the `make kubernetes-*` targets. Every Docker matrix job
uploads the JUnit report (`test/report/report.xml`) as artifact `bats-report-<case>`; when a job fails, `make logs` /
`make kubernetes-logs` print the service logs as collapsible groups. `.github/bin/prepare_env.sh <case>` builds `.env`
from `.env.dist` plus `.github/test-matrix/<case>.env`. The same workflow runs dive (image
efficiency), Trivy (vulnerabilities) and Popeye (cluster sanity). Further workflows: `lint.yml` (super-linter),
`docs.yml` (MkDocs strict build on pull requests, `gh-deploy` on `main`), `test-yaml-schema.yml` (`kustomize build` and
the pod security-context schema in `test/pajv/`), `release.yml` (conventional-changelog release; `update_image_tags.py`
pins the image tags inside the release tarball), `sync-next-branch.yml`, `renovate.yml`, `stale-issues.yml`,
`dockerhub.yml`, `cleanup-caches.yml`.

## Lint and formatting

`make lint` runs super-linter (`test/super-linter/compose.yaml`) with `.github/linters/super-linter.env` and
`super-linter-fix.env` (autofix enabled). Shell scripts: shfmt (tabs) and shellcheck; Markdown, YAML and JSON:
prettier; Dockerfiles: hadolint (`.hadolint.yaml`); Markdown rules in `.markdown-lint.yml` (lines up to 400 characters,
inline HTML allowed); prose is checked by textlint (terminology, e.g. "Git", "Docker"). `.bats` files are linted like
shell scripts.

## Git conventions

- Conventional commits (`feat(mta): ...`, `fix(kubernetes): ...`, `test: ...`, `docs: ...`, `chore(deps): ...`);
  `release.yml` derives the next version from them on every push to `main`.
- `main` is the released state; `next` collects breaking changes and is synced from `main` automatically
  (`sync-next-branch.yml`). Base pull requests on `main` unless they target the next major version.
- Renovate (`renovate.json`): digest pinning, grouped digest updates, automerge for minor, patch and digest updates,
  custom manager for `# renovate: depName=` comments. `deploy/**`, `docker-compose*.yml`, `docs/**` and
  `kustomization.yaml` are ignored because the image tags there are rewritten at release time.

## Key flows

- **DKIM:** mailserver-admin generates the key (`console dkim:setup <domain> --enable --selector dkim` or the web UI),
  stores it in the database and mirrors it into the Redis hash `dkim_keys` (field `dkim.<domain>`); `dkim:refresh`
  publishes all keys again on every `web` start. Rspamd (`target/filter/rootfs/etc/rspamd/local.d/dkim_signing.conf`,
  `use_redis`) signs authenticated and local mail for the header-From domain only when the TXT record
  `dkim._domainkey.<domain>` resolves and matches the private key (`check_pubkey = true`,
  `allow_pubkey_mismatch = false`); otherwise the mail leaves unsigned and without an error
  (`milter_default_action=accept`). `090_dkim.bats` publishes that record into the running unbound with
  `unbound-control local_data` before it sends mail, then rotates the key to prove that a stale record stops signing.
  `dkim:setup` sets the enabled flag from `--enable` on every call, so `--regenerate` without `--enable` disables signing
  for the domain.
- **DNS:** Only Rspamd resolves through `unbound` (`RSPAMD_DNS_SERVERS`); every other container uses the platform
  resolver. Unbound needs internet access, also for its healthcheck.
- **Spam learning:** Moving mail into or out of the Junk folder over IMAP runs Dovecot's `learn-spam`/`learn-ham` sieve
  scripts (`target/mda/rootfs/etc/dovecot/sieve/global/`), which pipe the message through
  `target/mda/rootfs/usr/local/lib/rspamc.sh` to the Rspamd controller (`FILTER_WEB_ADDRESS`, `CONTROLLER_PASSWORD`).
- **TLS:** `ssl` writes a self-signed certificate for `MAILNAME` into `data-tls`, which `mta`, `mda`, `web` (and mailpit
  in tests) mount read-only. See `docs/how-to/configure-tls.md` for real certificates.
