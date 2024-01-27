#!/usr/bin/env bash

# if arg = run, build image, then start the docker compose
# if arg = stop, then stop the docker compose, remove orphan containers, networks, and volumes
# if arg = clean, then stop the docker compose, remove orphan containers, networks, volumes, and images

if [ "$1" == "start" ]; then
    docker -f DOCKER/Dockerfile build -t mariadb:11.2-custom
    docker-compose -f DOCKER/docker-compose.yml up -d
elif [ "$1" == "stop" ]; then
    docker-compose -f DOCKER/docker-compose.yml stop
    docker-compose -f DOCKER/docker-compose.yml down -v --remove-orphans
    rm -rf DATA/mariadb/data/*
elif [ "$1" == "clean" ]; then
    docker-compose -f DOCKER/docker-compose.yml down --remove-orphans -v
    rm -rf DATA/mariadb/data/*
else
    echo "Invalid argument"
fi