# Makefile for zero-trust-dba project
SHELL := /bin/bash

# Variables
DOCKER_DIR=DOCKER
DOCKER_COMPOSE_FILE=DOCKER/docker-compose.yml
DOCKERFILE=DOCKER/Dockerfile
DATA_DIR=DATA
CONF_DIR=CONF
SCRIPTS_DIR=SCRIPTS

# Docker operations
.PHONY: start stop clean build prepare

start:
	cd $(DOCKER_DIR) && docker-compose up -d

stop:
	cd $(DOCKER_DIR) && docker-compose stop && docker-compose down -v --remove-orphans

clean:
	cd $(DOCKER_DIR) && docker-compose down --remove-orphans -v
	rm -rf $(DATA_DIR)/*

build:
	cd $(DOCKER_DIR) && docker build . -t mariadb:11.2-custom

prepare:
	sudo chmod +x $(SCRIPTS_DIR)/prepare.sh
	$(SCRIPTS_DIR)/prepare.sh

# Data management
.PHONY: clean-data load-sample-data

clean-data:
	@echo "Cleaning data directory..."
	rm -rf $(DATA_DIR)/*

