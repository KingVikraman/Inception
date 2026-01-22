wordpress.sh
#!/bin/bash

cd /var/www/html

if [ ! -f wp-config.php ]; then
        echo "Downloading WordPress..."
        wp core download --allow-root

        echo "Creating wp-config.php..."
        wp config create \
                --dbname=${MYSQL_DATABASE} \
                --dbuser=${MYSQL_USER} \
                --dbpass=${MYSQL_PASSWORD} \
                --dbhost=mariadb:3306 \
                --allow-root


        echo "Installing WordPress..."
        wp core install \
                --url=${DOMAIN_NAME} \
                --title="Inception" \
                --admin_user=${WP_ADMIN_USER} \
                --admin_password=${WP_ADMIN_PASSWORD} \
                --admin_email=${WP_ADMIN_EMAIL} \
                --allow-root


        echo "Creating additional user..."
        wp user create ${WP_USER} ${WP_USER_EMAIL} \
                --user_pass=${WP_USER_PASSWORD} \
                --role=author \
                --allow-root


        echo "WordPress setup complete."

fi

mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F