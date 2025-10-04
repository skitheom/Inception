#!/bin/bash
set -Eeuo pipefail

# SSL
if [ ! -f /etc/nginx/ssl/privkey.pem ]; then
  mkdir -p /etc/nginx/ssl
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/privkey.pem \
    -out /etc/nginx/ssl/cert.pem \
    -subj "/CN=${DOMAIN_NAME:-localhost}" -days 365
fi

# custom nginx conf
if [ -f /etc/nginx/conf.d/wordpress.conf.template ]; then
  envsubst '$DOMAIN_NAME' < /etc/nginx/conf.d/wordpress.conf.template \
    > /etc/nginx/conf.d/wordpress.conf
  rm /etc/nginx/conf.d/wordpress.conf.template
fi

echo "🚀 Starting nginx"
exec "$@"
