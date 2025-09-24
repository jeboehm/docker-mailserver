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

.PHONY: up
up: .env
	$(COMPOSE_PRODUCTION) up -d

.PHONY: fixtures
fixtures:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console domain:add example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console domain:add example.org
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --admin --password=changeme --enable admin example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --password=test1234 --enable --sendonly sendonly example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --password=test1234 --enable --quota=1 quota example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --password=test1234 disabled example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --password=test1234 --sendonly disabledsendonly example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --password=test1234 --enable fetchmailsource example.org
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console user:add --password=test1234 --enable fetchmailreceiver example.org
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console alias:add foo@example.com admin@example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console alias:add foo@example.org admin@example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console alias:add --catchall @example.com admin@example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console dkim:setup example.com --enable --selector dkim
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/wait-and-exec.sh /opt/manager/bin/console fetchmail:account:add --force fetchmailreceiver@example.org mda.local imap 31143 fetchmailsource@example.org test1234

.PHONY: setup
setup:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/setup.sh

.PHONY: lint
lint:
	docker run --platform linux/amd64 -e RUN_LOCAL=true --rm --env-file .github/linters/super-linter.env --env-file .github/linters/super-linter-fix.env -v $(PWD):/tmp/lint ghcr.io/super-linter/super-linter:v8.1.0

.PHONY: kubernetes-kind-images
kubernetes-kind-images:
	$(COMPOSE_TEST) build
	kind load docker-image jeboehm/mailserver-mda:latest
	kind load docker-image jeboehm/mailserver-mta:latest
	kind load docker-image jeboehm/mailserver-filter:latest
	kind load docker-image jeboehm/mailserver-web:latest
	kind load docker-image jeboehm/mailserver-unbound:latest
	docker tag docker-mailserver-test jeboehm/mailserver-test:latest
	kind load docker-image jeboehm/mailserver-test:latest

.PHONY: kubernetes-mysql
kubernetes-mysql:
	docker run -d --name db --network kind --env-file .env \
		-v ./target/db/rootfs/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d:ro \
		--env-file .env \
		mysql:lts

.PHONY: kubernetes-tls
kubernetes-tls:
	bin/create-tls-certs.sh
	kubectl create secret tls tls-certs --cert=config/tls/tls.crt --key=config/tls/tls.key

.PHONY: kubernetes-wait
kubernetes-wait:
	kubectl wait --timeout=5m --for=condition=ready pod -l app.kubernetes.io/name=docker-mailserver

.PHONY: kubernetes-test
kubernetes-test:
	kubectl delete -f test/bats/job.yaml --ignore-not-found
	kubectl apply -f test/bats/job.yaml
