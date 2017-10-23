#!/bin/bash

set -e

TIMEZONE=${TIMEZONE:-Europe/Moscow}

# set timezone
ln -snf /usr/share/zoneinfo/${PHP_TIMEZONE} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if [ -f /var/www/html/config/nginx/nginx.conf ]; then
    cp /var/www/html/config/nginx/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f /var/www/html/config/nginx/nginx-vhost.conf ]; then
    cp /var/www/html/config/nginx/nginx-vhost.conf /etc/nginx/conf.d/default.conf
fi

if [ -f /var/www/html/config/nginx/nginx-vhost-ssl.conf ]; then
    cp /var/www/html/config/nginx/nginx-vhost-ssl.conf /etc/nginx/conf.d/default-ssl.conf
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf

exec "$@"
