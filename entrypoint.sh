#!/bin/bash

# replace Akeneo env
cp /var/www/html/.env  /var/www/html/.env.local
sed -i "s/APP_DATABASE_HOST=*/APP_DATABASE_HOST=$AKENEO_MYSQL_HOST/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_PORT=*/APP_DATABASE_PORT=$AKENEO_MYSQL_PORT/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_NAME=*/APP_DATABASE_NAME=$AKENEO_MYSQL_HOST/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_USER=*/APP_DATABASE_USER=$AKENEO_MYSQL_USER/"  /var/www/html/.env.local
sed -i "s/APP_DATABASE_PASSWORD=*/APP_DATABASE_PASSWORD=$AKENEO_MYSQL_PASSWORD/"  /var/www/html/.env.local

# replace php.ini and fpm vars
sed -i "s/memory_limit = 128M/memory_limit = 512M/"  /etc/php/7.4/fpm/php.ini
sed -i "s/listen = 9000/listen = \/run\/php\/php7.4-fpm.sock/"  /etc/php/7.4/fpm/pool.d/www.conf

# to do: make prod  
cd /var/www/html && NO_DOCKER=true make prod 
chown -R www-data:www-data /var/www/html

# create administrator user
bin/console pim:user:create $AKENEO_ADMIN_USER $AKENEO_ADMIN_PASSWORD support@example.com Admin Admin en_US --admin -n --env=prod

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-1000}

usermod -u $USER_ID -o www-data && groupmod -g $USER_ID -o www-data
/etc/init.d/php7.4-fpm start
exec "$@"