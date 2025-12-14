COMPOSE_PRODUCTION = bin/production.sh
COMPOSE_TEST       = bin/test.sh

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

.PHONY: logs
logs:
	$(COMPOSE_PRODUCTION) logs db
	$(COMPOSE_PRODUCTION) logs ssl
	$(COMPOSE_PRODUCTION) logs mta
	$(COMPOSE_PRODUCTION) logs mda
	$(COMPOSE_PRODUCTION) logs filter
	$(COMPOSE_PRODUCTION) logs web
	$(COMPOSE_PRODUCTION) logs fetchmail
	$(COMPOSE_PRODUCTION) logs unbound
	$(COMPOSE_TEST) logs mailpit

.PHONY: up
up: .env
	$(COMPOSE_PRODUCTION) up -d

.PHONY: fixtures
fixtures:
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console system:check --wait
	sleep 5 # TODO: remove when admin implemented better checks
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console domain:add example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console domain:add example.org
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --admin --password=changeme --enable admin example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --password=test1234 --enable --sendonly sendonly example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --password=test1234 --enable --quota=1 quota example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --password=test1234 disabled example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --password=test1234 --sendonly disabledsendonly example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --password=test1234 --enable fetchmailsource example.org
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console user:add --password=test1234 --enable fetchmailreceiver example.org
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console alias:add foo@example.com admin@example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console alias:add foo@example.org admin@example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console alias:add --catchall @example.com admin@example.com
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console dkim:setup example.com --enable --selector dkim
	$(COMPOSE_PRODUCTION) exec web /opt/admin/bin/console fetchmail:account:add --force fetchmailreceiver@example.org mda.local imap 31143 fetchmailsource@example.org test1234

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
	kustomize build --load-restrictor=LoadRestrictionsNone test/k8s | kubectl apply -f -

.PHONY: kubernetes-tls
kubernetes-tls:
	bin/create-tls-certs.sh
	kubectl create secret tls tls-certs --cert=config/tls/tls.crt --key=config/tls/tls.key

.PHONY: kubernetes-wait
kubernetes-wait:
	kubectl wait --timeout=5m --for=condition=ready pod -l app.kubernetes.io/part-of=docker-mailserver

.PHONY: kubernetes-logs
kubernetes-logs:
	kubectl logs --ignore-errors -l app.kubernetes.io/name=fetchmail
	kubectl logs --ignore-errors -l app.kubernetes.io/name=filter
	kubectl logs --ignore-errors -l app.kubernetes.io/name=mda
	kubectl logs --ignore-errors -l app.kubernetes.io/name=mta
	kubectl logs --ignore-errors -l app.kubernetes.io/name=redis
	kubectl logs --ignore-errors -l app.kubernetes.io/name=unbound
	kubectl logs --ignore-errors -l app.kubernetes.io/name=web
	kubectl logs --ignore-errors -l app.kubernetes.io/name=mailpit
	kubectl logs --ignore-errors -l app.kubernetes.io/name=test-runner-job

.PHONY: kubernetes-test
kubernetes-test:
	kubectl delete -f test/k8s/test-job.yaml --ignore-not-found
	kubectl apply -f test/k8s/test-job.yaml
	kubectl wait --timeout=5m --for=condition=complete job -l app.kubernetes.io/name=test-runner-job
	kubectl logs --ignore-errors -l app.kubernetes.io/name=test-runner-job

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
	popeye
	.github/bin/popeye_score.sh

.PHONY: docs-build
docs-build:
	mkdocs build --strict -f .mkdocs.yaml

.PHONY: docs-serve
docs-serve:
	mkdocs serve --strict -f .mkdocs.yaml
