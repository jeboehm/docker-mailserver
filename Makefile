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

.PHONY: up
up: build
	$(compose-production) up

.PHONY: run-test
run-test: env clean build
	$(compose-test) build
	$(compose-production) up -d
	$(compose-test) run --rm test

.PHONY: clean
clean:
	$(compose-test) down -v

.PHONY: env
env:
	rm -f .env
	cp .env.dist .env

.PHONY: logs
logs:
	$(compose-production) logs ssl
	$(compose-production) logs mta
	$(compose-production) logs mda
	$(compose-production) logs web
	$(compose-production) logs db
	$(compose-production) logs spamassassin
