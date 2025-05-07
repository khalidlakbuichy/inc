#!/bin/bash
# Reset script

# Stop and remove containers
docker compose -f srcs/docker-compose.yml down

# Remove volumes
docker volume rm $(docker volume ls -q)

# Clean data directories
sudo rm -rf /home/$USER/data/wordpress/*
sudo rm -rf /home/$USER/data/mariadb/*

# build everything
make