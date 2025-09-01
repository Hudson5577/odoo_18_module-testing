# Odoo Docker Makefile
CONTAINER_ODOO = odoo
CONTAINER_DB = odoo-postgres
DOCKER_COMPOSE = docker compose
DOCKER = docker
WEB_DB_NAME = odoo

help:
	@echo "Available targets"
	@echo "  start       				Start the compose with daemon"
	@echo "  stop        				Stop the compose"
	@echo "  restart     				Restart the compose"
	@echo "  console     				Odoo interactive console"
	@echo "  psql        				PostgreSQL interactive shell"
	@echo "  logs odoo   				Logs the odoo container"
	@echo "  logs db     				Logs the postgresql container"
	@echo "  addon <addon_name>			Restart instance and upgrade addon"

start:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down

restart:
	$(DOCKER_COMPOSE) restart

console:
	$(DOCKER) exec -it $(CONTAINER_ODOO) odoo shell --db-host=$(CONTAINER_DB) -d $(WEB_DB_NAME) -r $(CONTAINER_ODOO) -w $(CONTAINER_ODOO)

psql:
	$(DOCKER) exec -it $(CONTAINER_DB) psql -U $(CONTAINER_ODOO) -d $(WEB_DB_NAME)

define log_target
	@if [ "$(1)" = "odoo" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_ODOO); \
	elif [ "$(1)" = "db" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_DB); \
	else \
		echo "Invalid logs target. Use 'make logs odoo' or 'make logs db'."; \
	fi
endef

logs:
	$(call log_target, $(word 2,$(MAKECMDGOALS)))

define upgrade_addon
	$(DOCKER) exec -it $(CONTAINER_ODOO) odoo --db-host=$(CONTAINER_DB) -d $(WEB_DB_NAME) -r $(CONTAINER_ODOO) -w $(CONTAINER_ODOO) -u $(1)
endef

addon: 
	$(call upgrade_addon, $(word 2,$(MAKECMDGOALS)))

# Prevent make from interpreting addon names as targets
%:
	@:

.PHONY: start stop restart console psql logs addon help