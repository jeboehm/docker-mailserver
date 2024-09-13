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
	$(COMPOSE_TEST) run --rm test

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
	$(COMPOSE_PRODUCTION) logs virus
	$(COMPOSE_PRODUCTION) logs web

.PHONY: up
up: .env
	$(COMPOSE_PRODUCTION) up -d

.PHONY: fixtures
fixtures:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console domain:add example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console domain:add example.org
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --admin --password=changeme --enable admin example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --enable --sendonly sendonly example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --enable --quota=1 quota example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 disabled example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console user:add --password=test1234 --sendonly disabledsendonly example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console alias:add foo@example.com admin@example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console alias:add foo@example.org admin@example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console alias:add --catchall @example.com admin@example.com
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/fixtures.sh /opt/manager/bin/console dkim:setup example.com --enable --selector 1337

.PHONY: unofficial-sigs
unofficial-sigs:
	cd virus/contrib/unofficial-sigs; docker build -t virus_unof_sig_updater .

.PHONY: setup
setup:
	$(COMPOSE_PRODUCTION) run --rm web /usr/local/bin/setup.sh
