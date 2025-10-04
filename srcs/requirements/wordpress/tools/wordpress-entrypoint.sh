#!/bin/bash
set -Eeuo pipefail

if [ -z "${WORDPRESS_DB_PASSWORD:-}" ] && [ -f /run/secrets/db_user_password ]; then
  WORDPRESS_DB_PASSWORD="$(cat /run/secrets/db_user_password)"
fi
if [ -z "${WORDPRESS_ADMIN_PASSWORD:-}" ] && [ -f /run/secrets/wp_admin_password ]; then
  WORDPRESS_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
fi
if [ -z "${WORDPRESS_AUTHOR_PASSWORD:-}" ] && [ -f /run/secrets/wp_author_password ]; then
  WORDPRESS_AUTHOR_PASSWORD="$(cat /run/secrets/wp_author_password)"
fi

echo "Waiting for MariaDB 🐾..."
counter=0
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    sleep 3
    counter=$((counter+1))
    if [ $counter -gt 20 ]; then
        echo "MariaDB did not respond in time."
        exit 1
    fi
done
echo "MariaDB is up!"

if [ ! -f wp-config.php ]; then
    if [ ! -f index.php ] || [ ! -f wp-includes/version.php ]; then
        echo "WordPress core not found, downloading..."
        wp core download --allow-root
    fi

    echo "Creating wp-config.php..."
    wp config create \
      --dbname="$WORDPRESS_DB_NAME" \
      --dbuser="$WORDPRESS_DB_USER" \
      --dbpass="$WORDPRESS_DB_PASSWORD" \
      --dbhost="$WORDPRESS_DB_HOST" \
      --allow-root

    # Admin
    echo "Installing WordPress..."
    wp core install \
      --url="$WORDPRESS_URL" \
      --title="$WORDPRESS_TITLE" \
      --admin_user="$WORDPRESS_ADMIN_USER" \
      --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
      --admin_email="$WORDPRESS_ADMIN_EMAIL" \
      --allow-root


    # Author
    if ! wp user get "$WORDPRESS_AUTHOR" --allow-root > /dev/null 2>&1; then
    echo "Creating additional WordPress user..."
    wp user create \
        "$WORDPRESS_AUTHOR" \
        "$WORDPRESS_AUTHOR_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_AUTHOR_PASSWORD" \
        --allow-root
    fi
fi

# Fix permissions for WordPress files
chown -R www-data:www-data /var/www/html

echo "Starting WordPress with php-fpm..."
exec "$@"
