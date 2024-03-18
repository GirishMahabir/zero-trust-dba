# Makefile for zero-trust-dba project
SHELL := /bin/bash

# Variables
DOCKER_DIR=DOCKER
DOCKER_COMPOSE_FILE=DOCKER/docker-compose.yml
DATA_DIR=DATA
CONF_DIR=CONF
SCRIPTS_DIR=SCRIPTS

# Docker operations
.PHONY: start stop ps stats clean build prepare

start:
	cd $(DOCKER_DIR) && docker-compose up -d

stop:
	cd $(DOCKER_DIR) && docker-compose stop && docker-compose down -v --remove-orphans

ps:
	cd $(DOCKER_DIR) && docker-compose ps

stats:
	cd $(DOCKER_DIR) && docker-compose stats --no-stream

clean:
	cd $(DOCKER_DIR) && docker-compose down --remove-orphans -v
	sudo rm -rf $(DATA_DIR)/*

build:
	cd $(DOCKER_DIR) && docker build . -t mariadb:11.2-custom --no-cache

prepare:
	sudo chmod +x $(SCRIPTS_DIR)/prepare.sh
	$(SCRIPTS_DIR)/prepare.sh