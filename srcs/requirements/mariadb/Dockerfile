FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure MariaDB to accept connections from any IP
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy custom configuration
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Copy setup script
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

# Start setup and run MariaDB server
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["mysqld_safe"]