# Agent instructions for the documentation

This file applies to everything under `docs/` and to `.mkdocs.yaml`. Project-wide conventions (services, deployment, tests, CI, Git) are described in the root [`AGENTS.md`](../AGENTS.md).

## Documentation framework: Diátaxis

Documentation follows **[Diátaxis](https://diataxis.fr)** (“A systematic approach to technical documentation authoring”). Diátaxis defines four kinds of documentation, each with a different purpose and style:

| Kind             | Purpose                      | Serves                       | Style                                                                                                                      |
| ---------------- | ---------------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Tutorial**     | Learning by doing            | Acquisition of skill (study) | Lesson: take the learner through a concrete path; minimal explanation; visible results early; one main path, no branching. |
| **How-to guide** | Accomplish a specific task   | Application of skill (work)  | Task-oriented: clear steps to reach a goal; for users who already know what they want; no teaching, no long explanations.  |
| **Reference**    | Look up facts                | Application of skill (work)  | Technical description: accurate, complete, neutral; structure mirrors the product; consulted, not read.                    |
| **Explanation**  | Understand context and “why” | Acquisition of skill (study) | Background and discussion: design, trade-offs, connections; can include opinion and perspective.                           |

**Guidelines:**

- **Tutorials:** One or few. One main path; show the result early; avoid options and long explanations; link to reference/explanation for depth.
- **How-to guides:** One goal per guide; title = “How to …”; steps only; link to reference for options and formats.
- **Reference:** Describe the machinery (env vars, ports, record formats, APIs); austere; structured like the product; no instruction or opinion.
- **Explanation:** Answer “why?” and “how does it fit together?”; can compare alternatives and give context; do not mix in procedures or reference tables.

Do not mix the four types in a single doc. When in doubt, use the [Diátaxis compass](https://diataxis.fr/compass/): “Does it inform action or cognition? Does it serve study or work?”

## Documentation structure

The docs are organised by Diátaxis type:

- **`README.md`** — Landing page (“Welcome” in the nav).
- **`tutorials/`** — Learning path (e.g. `getting-started.md`).
- **`how-to/`** — Task guides: install (Docker/Kubernetes), upgrade, configure (DNS, DKIM, TLS, relay, reverse proxy, OAuth2, database, Roundcube, PHP sessions), manage (domains, users, aliases, fetchmail), validate DNS, iOS/macOS profile.
- **`reference/`** — Technical reference: `environment-variables.md`, `ports.md`, `dns-records.md`, `service-architecture.md`, `user-roles.md`, `mailserver-admin-config.md`, `local-address-extension.md`, `upgrade-changelog.md`.
- **`explanation/`** — Context: `architecture.md`, `database-backends.md`, `dns-and-email.md`, `observability.md`.
- **`administration/`** — Short reference for the web UI: `login.md`, `dashboard.md`; other admin topics live as how-to or reference.
- **`development/`** — Developer how-to: `development.md` (Make, test, lint), `mailserver-admin.md` (mailserver-admin repository setup).
- **`example-configs/`** — Ready-to-use Compose and Kustomize recipes. Excluded from the MkDocs build; the “Recipes” nav entries link to them on GitHub.
- **`images/`**, **`logo/`** — Screenshots (`images/admin/`) and logos.
- **`requirements.txt`** — pip requirements for MkDocs (excluded from the build, like this file).

MkDocs config is **`.mkdocs.yaml`**; the `nav` there reflects this structure (Tutorial, How-to guides, Reference, Administration, Explanation, Recipes, Development).

## Documentation writing style

- Use **technical documentation language**, not marketing. Avoid subjective terms (“powerful”, “particularly useful”, “sophisticated”).
- Use **direct, factual** statements about what the software does. Include **technical references** (e.g. RFCs) and **concrete examples** where useful.
- Focus on **implementation and configuration**; keep prose concise and suitable for technical readers.
- Prefer **functional descriptions** over promotional copy.

## MkDocs

- `make docs-build` runs `mkdocs build --strict -f .mkdocs.yaml`. Strict mode fails when a page is missing from `nav` (unless listed in `exclude_docs`) or when a relative link does not resolve to a built page. `make docs-serve` starts a live preview. Install the tooling with `pip install -r docs/requirements.txt`.
- Theme is `readthedocs`; enabled Markdown extensions are `admonition`, `pymdownx.fancylists` and `pymdownx.superfences`.
- `.github/workflows/docs.yml` runs the strict build on pull requests that touch `docs/`, `.mkdocs.yaml` or the workflow itself, and publishes with `mkdocs gh-deploy` on every push to `main`.
- Markdown is formatted by prettier and checked by markdownlint through `make lint` (`.github/linters/.markdown-lint.yml`: long lines, inline HTML and bare URLs are allowed).

## Quick reference for agents

- **Adding a new feature that needs docs:** Add or update the right Diátaxis type (tutorial step, how-to, reference section, or explanation). Keep one purpose per doc; link between them.
- **Adding env vars or ports:** Document in **`reference/environment-variables.md`** or **`reference/ports.md`**; mention in the relevant how-to if it affects a procedure. Keep `reference/environment-variables.md` in sync with `.env.dist` and `deploy/kustomize/common/configmap.yaml`.
- **Adding a new page:** Create it under the matching directory (how-to guides get a “How to …” title) and add it to **`.mkdocs.yaml`** under the matching nav section, otherwise the strict build fails.
- **Changing deployment (Compose or Kustomize):** See the deployment parity rule in the root `AGENTS.md`; update `how-to/install-docker.md` / `how-to/install-kubernetes.md` and the reference pages when user-visible behaviour changes.
- **Upgrades with user impact:** Record them in **`reference/upgrade-changelog.md`** and, if steps are needed, in **`how-to/upgrade.md`**.
