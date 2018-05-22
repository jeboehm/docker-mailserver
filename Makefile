COMPOSE_PRODUCTION = bin/production.sh
COMPOSE_TEST       = bin/test.sh

.PHONY: build
build:
	$(COMPOSE_TEST) build --pull

.PHONY: test
test: .env clean build up fixtures
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

.PHONY: up
up:
	$(COMPOSE_PRODUCTION) up -d

.PHONY: fixtures
fixtures:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --sendonly sendonly example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --quota=1 quota example.com

.PHONY: ci
ci: test unofficial-sigs

.PHONY: unofficial-sigs
unofficial-sigs:
	cd virus/contrib/unofficial-sigs; docker build -t virus_unof_sig_updater .
