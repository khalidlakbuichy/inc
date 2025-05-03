#!/bin/bash

# Create necessary directories for PHP-FPM
mkdir -p /run/php

# Wait for MariaDB to be ready with better error handling
echo "Waiting for MariaDB to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW DATABASES;" &>/dev/null; then
        echo "Successfully connected to MariaDB!"
        break
    fi
    
    attempt=$((attempt+1))
    echo "Attempt $attempt/$max_attempts: MariaDB not ready yet, waiting..."
    sleep 5
    
    if [ $attempt -eq $max_attempts ]; then
        echo "Error: Could not connect to MariaDB after $max_attempts attempts"
        echo "Debug information:"
        echo "- Trying to connect to host: mariadb"
        echo "- Using user: ${MYSQL_USER}"
        echo "- Database target: ${MYSQL_DATABASE}"
        ping -c 3 mariadb || echo "Cannot ping mariadb host"
        exit 1
    fi
done

# Check if WordPress is already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --extra-php <<PHP
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
PHP
    
    echo "Installing WordPress..."
    wp core install --allow-root \
        --url=${DOMAIN_NAME} \
        --title=${WP_TITLE} \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL}
    
    echo "Creating additional WordPress user..."
    wp user create --allow-root \
        ${WP_USER} ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author
    
    echo "WordPress setup completed!"
else
    echo "WordPress is already installed!"
fi

# Make sure the directory is owned by www-data
chown -R www-data:www-data /var/www/html

# Start PHP-FPM
exec "$@"