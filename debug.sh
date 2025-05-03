#!/bin/bash
# Debug script to help diagnose issues with Docker containers

echo "===== CHECKING DOCKER CONTAINERS STATUS ====="
docker ps -a

echo -e "\n===== CHECKING DOCKER NETWORKS ====="
docker network ls
docker network inspect inception_network

echo -e "\n===== CHECKING MARIADB LOGS ====="
docker logs mariadb

echo -e "\n===== CHECKING WORDPRESS LOGS ====="
docker logs wordpress

echo -e "\n===== CHECKING NGINX LOGS ====="
docker logs nginx

echo -e "\n===== CHECKING MARIADB CONNECTION FROM WORDPRESS CONTAINER ====="
docker exec wordpress mariadb -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;"

echo -e "\n===== CHECKING IF WORDPRESS FILES ARE PROPERLY MOUNTED ====="
docker exec wordpress ls -la /var/www/html/

echo -e "\n===== CHECKING WORDPRESS CONFIG ====="
docker exec wordpress cat /var/www/html/wp-config.php 2>/dev/null || echo "wp-config.php not found"