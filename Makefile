compose-production = bin/production.sh
compose-test       = bin/test.sh

.PHONY: build
build:
	$(compose-production) build

.PHONY: pull
pull:
	$(compose-production) pull

.PHONY: test
test: run-test logs

.PHONY: run-test
run-test: env clear-test build
	$(compose-test) build
	$(compose-production) up -d
	sleep 60
	$(compose-test) run --rm test /opt/tests/run-tests.sh

.PHONY: clear-test
clear-test:
	$(compose-test) down -v

.PHONY: env
env:
	rm -f .env
	cp .env.dist .env

.PHONY: logs
logs:
	$(compose-production) logs
