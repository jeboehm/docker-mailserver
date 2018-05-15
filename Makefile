COMPOSE_PRODUCTION = bin/production.sh
COMPOSE_TEST       = bin/test.sh

.PHONY: build
build:
	$(COMPOSE_PRODUCTION) build --pull

.PHONY: test
test: .env clean build
	$(COMPOSE_TEST) build
	$(COMPOSE_PRODUCTION) up -d
	$(COMPOSE_TEST) run --rm test

.PHONY: clean
clean:
	$(COMPOSE_TEST) down -v

.env:
	rm -f .env
	cp .env.dist .env

.PHONY: logs
logs:
	$(COMPOSE_PRODUCTION) logs db
	$(COMPOSE_PRODUCTION) logs ssl
	$(COMPOSE_PRODUCTION) logs mta
	$(COMPOSE_PRODUCTION) logs mda
	$(COMPOSE_PRODUCTION) logs filter
	$(COMPOSE_PRODUCTION) logs virus
	$(COMPOSE_PRODUCTION) logs web
