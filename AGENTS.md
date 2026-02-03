# Agent instructions for docker-mailserver

This file gives AI agents and contributors the project conventions, documentation framework, and structure they need to work consistently on the codebase and docs.

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

## Documentation structure (docs/)

The docs are organised by Diátaxis type:

- **`tutorials/`** — Learning path (e.g. `getting-started.md`).
- **`how-to/`** — Task guides: install (Docker/Kubernetes), upgrade, configure (DNS, DKIM, TLS, relay, reverse proxy, OAuth2, MySQL, Roundcube, PHP sessions), manage (domains, users, aliases, fetchmail), iOS/macOS profile.
- **`reference/`** — Technical reference: `environment-variables.md`, `ports.md`, `dns-records.md`, `service-architecture.md`, `user-roles.md`, `mailserver-admin-config.md`, `local-address-extension.md`, `upgrade-changelog.md`.
- **`explanation/`** — Context: `architecture.md`, `dns-and-email.md`, `observability.md`.
- **`administration/`** — Short reference for the web UI: `login.md`, `dashboard.md`; other admin topics live as how-to or reference and are linked from here.
- **`configuration/`** — Legacy entry points; these files redirect to the appropriate how-to or reference.
- **`development/`** — Developer how-to: `development.md` (Make, test, lint), `mailserver-admin.md` (mailserver-admin repository setup); `architecture.md` redirects to reference + explanation.
- **`observability/`** — `intro.md` redirects to `explanation/observability.md`.

MkDocs config is **`.mkdocs.yaml`**; the `nav` there reflects this structure (Tutorial, How-to guides, Reference, Administration, Explanation, Recipes, Development).

## Documentation writing style

- Use **technical documentation language**, not marketing. Avoid subjective terms (“powerful”, “particularly useful”, “sophisticated”).
- Use **direct, factual** statements about what the software does. Include **technical references** (e.g. RFCs) and **concrete examples** where useful.
- Focus on **implementation and configuration**; keep prose concise and suitable for technical readers.
- Prefer **functional descriptions** over promotional copy.

## Project structure

- **Architecture:** The mailserver is made of multiple containers/pods (MTA, MDA, Web, Filter, SSL, Database, Redis, Unbound, Fetchmail) that together provide mail and management.
- **Container images:** Built under **`target/`**. Each subdirectory is one service (e.g. `target/mta/`, `target/mda/`, `target/filter/`, `target/web/`, `target/db/`, `target/unbound/`, `target/ssl/`).
- **Deployment manifests:**
  - **Docker Compose:** `deploy/compose/` (e.g. `mta.yaml`, `mda.yaml`, `web.yaml`, `db.yaml`).
  - **Kubernetes (Kustomize):** `deploy/kustomize/` (e.g. `mta/`, `mda/`, `web/`, `ingress/`).
- **Deployment consistency:** The same capabilities should be reflected in both Compose and Kustomize. When you change one (e.g. env vars, volumes, services), update the other so Docker and Kubernetes deployments stay in parity.

## Quick reference for agents

- **Adding a new feature that needs docs:** Add or update the right Diátaxis type (tutorial step, how-to, reference section, or explanation). Keep one purpose per doc; link between them.
- **Adding env vars or ports:** Document in **`reference/environment-variables.md`** or **`reference/ports.md`**; mention in the relevant how-to if it affects a procedure.
- **Adding a new how-to:** Create under **`how-to/`** with a “How to …” title; add the page to **`.mkdocs.yaml`** under “How-to guides”.
- **Changing deployment (Compose or Kustomize):** Apply the same logical change in **`deploy/compose/`** and **`deploy/kustomize/`** where applicable.
