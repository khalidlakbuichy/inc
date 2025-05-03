#!/bin/bash

# Create the directory for MySQL socket
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chmod 777 /var/run/mysqld

# Initialize MySQL data directory
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MySQL data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL service temporarily to setup users
/usr/bin/mysqld_safe --user=mysql &

# Wait for MySQL to start up properly
echo "Waiting for MySQL server to start..."
until mysqladmin ping &>/dev/null; do
    sleep 2
done
echo "MySQL is up and running"

# Make sure the database and users are created
echo "Creating database and users..."
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Print status for debugging
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"

# Stop the temporary MySQL instance
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

echo "MariaDB setup completed!"

# Execute the command passed as parameter
exec "$@"