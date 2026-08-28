COMPOSE_PRODUCTION = bin/production.sh
COMPOSE_TEST       = bin/test.sh

# Services whose logs `make logs` / `make kubernetes-logs` print.
COMPOSE_SERVICES    = db ssl mta mda filter web fetchmail unbound redis mailpit
KUBERNETES_SERVICES = db fetchmail filter mda mta redis unbound web mailpit test-runner-job

# The kubernetes test overlay follows the database engine configured in .env.
# Override with e.g. `make kubernetes-deploy-helper DB_DRIVER=pgsql`.
DB_DRIVER ?= $(shell sed -n 's/^DB_DRIVER=//p' .env 2>/dev/null | tail -n1)
DB_DRIVER := $(or $(strip $(DB_DRIVER)),mysql)

.PHONY: prod
prod: up

.PHONY: build
build:
	$(COMPOSE_TEST) build

.PHONY: pull
pull:
	$(COMPOSE_PRODUCTION) pull

.PHONY: test
test: up fixtures
	$(COMPOSE_TEST) run --build --rm test

.PHONY: clean
clean:
	$(COMPOSE_TEST) down -v --remove-orphans

.env:
	cp .env.dist .env

# Logs of every service, one block per service. In GitHub Actions the blocks
# are folded into groups.
.PHONY: logs
logs:
	@for service in $(COMPOSE_SERVICES); do \
		[ -z "$$GITHUB_ACTIONS" ] || echo "::group::$$service"; \
		$(COMPOSE_TEST) logs $$service; \
		[ -z "$$GITHUB_ACTIONS" ] || echo "::endgroup::"; \
	done

.PHONY: up
up: .env
	$(COMPOSE_PRODUCTION) up -d

.PHONY: fixtures
fixtures:
	$(COMPOSE_PRODUCTION) exec -T web sh < test/fixtures.sh

.PHONY: setup
setup:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/setup.sh

.PHONY: lint
lint:
	docker compose -f test/super-linter/compose.yaml run --rm super-linter

.PHONY: frankenphplint
frankenphplint:
	docker run --rm -v ./target/web/rootfs/etc/frankenphp/:/etc/frankenphp jeboehm/mailserver-web:latest frankenphp fmt --overwrite /etc/frankenphp/Caddyfile

.PHONY: kubernetes-deploy-helper
kubernetes-deploy-helper:
	helm repo add traefik https://traefik.github.io/charts
	helm repo update
	helm upgrade --install traefik traefik/traefik --version 37.1.2 --namespace default --values test/k8s/traefik-values.yaml
	kustomize build --load-restrictor=LoadRestrictionsNone test/k8s/$(DB_DRIVER) | kubectl apply -f -

.PHONY: kubernetes-tls
kubernetes-tls:
	bin/create-tls-certs.sh
	kubectl create secret tls tls-certs --cert=config/tls/tls.crt --key=config/tls/tls.key

.PHONY: kubernetes-wait
kubernetes-wait:
	kubectl wait --timeout=5m --for=condition=ready pod -l app.kubernetes.io/part-of=docker-mailserver

.PHONY: kubernetes-logs
kubernetes-logs:
	@for service in $(KUBERNETES_SERVICES); do \
		[ -z "$$GITHUB_ACTIONS" ] || echo "::group::$$service"; \
		kubectl logs --ignore-errors --tail=-1 -l app.kubernetes.io/name=$$service; \
		[ -z "$$GITHUB_ACTIONS" ] || echo "::endgroup::"; \
	done

# Runs the test job, prints the runner log whatever the outcome and fails
# unless the job completed. Polling instead of `kubectl wait` so that a
# failed job is reported at once rather than after the timeout.
.PHONY: kubernetes-test
kubernetes-test:
	kubectl delete -f test/k8s/test-job.yaml --ignore-not-found
	kubectl apply -f test/k8s/test-job.yaml
	@status=""; \
	for _ in $$(seq 1 60); do \
		status="$$(kubectl get job test-runner-job -o jsonpath='{.status.conditions[?(@.status=="True")].type}')"; \
		case "$$status" in *Complete* | *Failed*) break ;; esac; \
		sleep 5; \
	done; \
	kubectl logs --ignore-errors --tail=-1 -l app.kubernetes.io/name=test-runner-job; \
	echo "Job conditions: $${status:-none (timeout)}"; \
	case "$$status" in *Complete*) exit 0 ;; *) exit 1 ;; esac

.PHONY: kubernetes-up
kubernetes-up:
	kubectl apply -k .

.PHONY: kubernetes-down
kubernetes-down:
	kubectl delete -f test/k8s/test-job.yaml --ignore-not-found
	kubectl delete -k .

.PHONY: kind-load
kind-load: build
	kind load docker-image jeboehm/mailserver-mda:latest
	kind load docker-image jeboehm/mailserver-mta:latest
	kind load docker-image jeboehm/mailserver-filter:latest
	kind load docker-image jeboehm/mailserver-web:latest
	kind load docker-image jeboehm/mailserver-unbound:latest
	kind load docker-image jeboehm/mailserver-test:latest

.PHONY: popeye-score
popeye-score:
	.github/bin/popeye_score.sh

.PHONY: docs-build
docs-build:
	mkdocs build --strict -f .mkdocs.yaml

.PHONY: docs-serve
docs-serve:
	mkdocs serve --watch docs/ --strict -f .mkdocs.yaml
