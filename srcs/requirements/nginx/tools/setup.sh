#!/bin/bash

# replace the following variables with your actual values
sed -i "s|## SSL_BLOCK ##|server_name $DOMAIN_NAME;\n    ssl_certificate $SSL_CERT;\n    ssl_certificate_key $SSL_KEY;|" /etc/nginx/sites-available/default

# Create the directory for Nginx
exec "$@"