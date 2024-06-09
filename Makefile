.PHONY: build run stop ps host

define PRINT_HELP_PYSCRIPT
import re, sys

regex_pattern = r'^([a-zA-Z_-]+):.*?## (.*)$$'

for line in sys.stdin:
	match = re.match(regex_pattern, line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean-logs: # Removes log info. Usage: make clean-logs
	rm -fr build/ dist/ .eggs/
	find . -name '*.log' -o -name '*.log' -exec rm -fr {} +

clean-test: # Remove test and coverage artifacts
	rm -fr .tox/ .testmondata* .coverage coverage.* htmlcov/ .pytest_cache

clean-cache: # remove test and coverage artifacts
	find . -name '*pycache*' -exec rm -rf {} +

clean: clean-logs clean-test clean-cache ## Add a rule to remove unnecessary assets. Usage: make clean

env: ## Creates a virtual environment. Usage: make env
	pip install virtualenv
	virtualenv .venv

install: ## Installs the python requirements. Usage: make install
	pip install uv
	uv pip install -r requirements.txt

search: ## Searchs for a token in the code. Usage: make search token=your_token
	grep -rnw . \
	--exclude-dir=venv \
	--exclude-dir=.git \
	--exclude=poetry.lock \
	-e "$(token)"

replace: ## Replaces a token in the code. Usage: make replace token=your_token
	sed -i 's/$(token)/$(new_token)/g' $$(grep -rl "$(token)" . \
		--exclude-dir=venv \
		--exclude-dir=.git \
		--exclude=poetry.lock)

minimal-requirements: ## Generates minimal requirements. Usage: make minimal-requirements
	python3 scripts/clean_packages.py requirements.txt requirements.txt

ip: ## Get the IP of the container. Usage: make ip
	docker inspect $(container) | jq -r '.[0].NetworkSettings.Networks[].IPAddress'

ip-db: ## Get the database IP. Usage: make db-ip
	$(MAKE) ip container=db

inspect: ## Inspect the container. Usage: make inspect
	docker inspect $(container)

inspect-db: ## Inspect the db container. Usage: make inspect-db
	$(MAKE) inspect container=db

kill-container: ## Kill the database container. Usage: make kill-db
	docker inspect $(container) | jq -r '.[0].State.Pid' | sudo xargs kill -9

kill-db: ## Kill the database container. Usage: make kill-db
	$(MAKE) kill-container container=db

logs: ## Show the logs of the  container. Usage: make log-cron
	docker logs -f $(container)

logs-db: ## Show the logs of the db container. Usage: make log-cron
	$(MAKE) logs container=db

exec: ## Execute a command in the container. Usage: make exec container="cron-task" command="ls -la"
	docker exec -it $(container) $(command)

psql: ## Execute a command in the container. Usage: make exec container="cron-task" command="ls -la"
	$(MAKE) exec container=db command="psql -U postgres"

bash: ## Execute a bash in the container. Usage: make bash
	$(MAKE) exec container=$(container) command="/bin/bash"

bash-db: ## Execute a bash in the db container. Usage: make bash-db
	$(MAKE) bash container=db

build: ## Build the containers. Usage: make build
	docker-compose build

up: ## Start the containers. Usage: make up
	docker-compose up -d

down: ## Stop the containers. Usage: make down
	docker-compose down

restart: down build up ## Restart the containers. Usage: make restart

ps: ## List the containers. Usage: make ps
	docker ps -a

prune: ## Remove all containers. Usage: make prune
	docker system prune

lint: ## perform inplace lint fixes
	ruff check --fix .

