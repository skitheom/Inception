WORDPRESS_DATA_DIR  := $(HOME)/data/wordpress
MARIADB_DATA_DIR    := $(HOME)/data/mariadb
WORDPRESS_IMAGE		:= inception-wordpress
MARIADB_IMAGE		:= inception-mariadb
NGINX_IMAGE			:= inception-nginx
WORDPRESS_VOLUME	:= inception_wordpress
MARIADB_VOLUME 		:= inception_mariadb

DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE            := ./srcs/.env
ENV_SAMPLE_FILE		:= ./srcs/.env.sample

COMPOSE := docker compose --env-file $(ENV_FILE) -f $(DOCKER_COMPOSE_FILE)

all: build

setup_env:
	@test -f $(ENV_FILE) || cp $(ENV_SAMPLE_FILE) $(ENV_FILE)

setup_dirs:
	@test -n "$(HOME)" || (echo "HOME is empty" && exit 1)
	@mkdir -p "$(WORDPRESS_DATA_DIR)" "$(MARIADB_DATA_DIR)"

build: setup_env setup_dirs
	@$(COMPOSE) up -d --build

up:
	@$(COMPOSE) up -d --remove-orphans

down:
	@$(COMPOSE) down

re: down build

clean: down
	@echo "🗑️  Removing named Docker volumes..."
	@docker volume rm -f $(MARIADB_VOLUME) $(WORDPRESS_VOLUME) || true
	@echo "🧹 Cleaning data directories..."
	@rm -rf "$(WORDPRESS_DATA_DIR)" "$(MARIADB_DATA_DIR)"
	@echo "🧼 Pruning dangling networks/volumes..."
	@docker network prune --force
	@docker volume prune --force

fclean: clean
	@echo "🔥 Removing built images..."
	@docker rmi -f $(MARIADB_IMAGE) $(WORDPRESS_IMAGE) $(NGINX_IMAGE) || true

status:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f

.PHONY: all setup_dirs build up down re clean status logs
