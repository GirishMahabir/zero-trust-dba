# Makefile for zero-trust-dba project
SHELL := /bin/bash

# Variables
DOCKER_DIR=DOCKER
DOCKER_COMPOSE_FILE=DOCKER/docker-compose.yml
DATA_DIR=DATA
CONF_DIR=CONF
SCRIPTS_DIR=SCRIPTS
ALERTS_DIR=ALERT-APP-DEMO

# Docker operations
.PHONY: start stop ps stats clean build prepare

start:
	mkdir -p $(DATA_DIR)
	cd $(DOCKER_DIR) && docker-compose pull
	cd $(DOCKER_DIR) && docker-compose up -d

stop:
	cd $(DOCKER_DIR) && docker-compose stop && docker-compose down -v --remove-orphans

ps:
	cd $(DOCKER_DIR) && docker-compose ps

stats:
	cd $(DOCKER_DIR) && docker-compose stats --no-stream

clean:
	cd $(DOCKER_DIR) && docker-compose down --remove-orphans -v
	sudo rm -rf $(DATA_DIR)/mariadb*
	sudo rm -rf $(DATA_DIR)/proxysql*

build:
	cd $(DOCKER_DIR) && docker build . -t ghcr.io/girishmahabir/zero-trust-dba/mariadb-11.2:master --no-cache

prepare:
	mkdir -p $(DATA_DIR)
	sudo chmod +x $(SCRIPTS_DIR)/prepare.sh
	$(SCRIPTS_DIR)/prepare.sh