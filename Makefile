DATA_DIR            := $(HOME)/data
WORDPRESS_DATA_DIR  := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR    := $(DATA_DIR)/mariadb
PORTAINER_DATA_DIR  := $(DATA_DIR)/portainer

PROJECT             := srcs
DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE            := ./srcs/.env

COMPOSE := docker compose --env-file $(ENV_FILE) -p $(PROJECT) -f $(DOCKER_COMPOSE_FILE)

MARIADB_VOLUME   ?= $(PROJECT)_mariadb
WORDPRESS_VOLUME ?= $(PROJECT)_wordpress
PORTAINER_VOLUME ?= $(PROJECT)_portainer

.PHONY: all setup_dirs build up down re clean status logs

all: build

setup_dirs:
	@test -n "$(HOME)" || (echo "HOME is empty" && exit 1)
	@mkdir -p "$(WORDPRESS_DATA_DIR)" "$(MARIADB_DATA_DIR)" "$(PORTAINER_DATA_DIR)"

build: setup_dirs
	@$(COMPOSE) up -d --build

up:
	@$(COMPOSE) up -d --remove-orphans

down:
	@$(COMPOSE) down

re: down build

clean: down
	@echo "🗑️  Removing named Docker volumes..."
	@docker volume rm -f $(MARIADB_VOLUME) $(WORDPRESS_VOLUME) $(PORTAINER_VOLUME) || true
	@echo "🧹 Cleaning data directories..."
	@rm -rf "$(WORDPRESS_DATA_DIR)" "$(MARIADB_DATA_DIR)" "$(PORTAINER_DATA_DIR)"
	@echo "🧼 Pruning dangling networks/volumes..."
	@docker network prune --force
	@docker volume prune --force

status:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f

.PHONY: all setup_dirs build up down re clean status logs