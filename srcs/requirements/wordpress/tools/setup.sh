#!/bin/bash

# Create necessary directories for PHP-FPM
mkdir -p /run/php

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready!"

# Check if WordPress is already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb
    
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
    
    echo "Setting up Redis cache..."
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
    
    echo "WordPress setup completed!"
else
    echo "WordPress is already installed!"
fi

# Make sure the directory is owned by www-data
chown -R www-data:www-data /var/www/html

# Start PHP-FPM
exec "$@"