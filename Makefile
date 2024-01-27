# Makefile for zero-trust-dba project

# Variables
DOCKER_COMPOSE_FILE=DOCKER/docker-compose.yml
DOCKERFILE=DOCKER/Dockerfile
DATA_DIR=DATA/mariadb/data
CONF_DIR=CONF
SAMPLE_DATA_DIR=DATA/sample_data
SCRIPTS_DIR=SCRIPTS

# Docker operations
.PHONY: start stop clean build

start:
	@bash run.sh start

stop:
	@bash run.sh stop

clean:
	@bash run.sh clean

build:
	docker -f $(DOCKERFILE) build -t mariadb:11.2-custom

# Data management
.PHONY: clean-data load-sample-data

clean-data:
	@echo "Cleaning data directory..."
	@rm -rf $(DATA_DIR)/*

load-sample-data:
	@echo "Loading sample data..."
	# Add commands to load sample data into your database or data directory here

# Configuration management
.PHONY: list-config backup-config restore-config

list-config:
	@echo "Listing configuration files..."
	@ls $(CONF_DIR)

backup-config:
	@echo "Backing up configuration files..."
	# Add commands to backup your configuration files here

restore-config:
	@echo "Restoring configuration files from backup..."
	# Add commands to restore your configuration files from backup here

# Miscellaneous scripts
.PHONY: run-script

run-script:
	@echo "Running scripts..."
	# Add commands to execute scripts from the SCRIPTS_DIR here