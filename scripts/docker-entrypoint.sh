#!/bin/bash

set -e

TIMEZONE=${TIMEZONE:-Europe/Moscow}
FPM_HOST=${FPM_HOST:-phpfpm}
FPM_PORT=${FPM_PORT:-9000}
NGINX_WORKERS=${NGINX_WORKERS:2}

# set timezone
ln -snf /usr/share/zoneinfo/${PHP_TIMEZONE} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if [ -f /var/www/html/config/nginx/nginx.conf ]; then
    cp /var/www/html/config/nginx/nginx.conf /etc/nginx/nginx.conf
else

    sed -i \
        -e "s/NGINX_WORKERS/${NGINX_WORKERS}/g" \
        /etc/nginx/nginx.conf

fi

if [ -f /var/www/html/config/nginx/nginx-vhost.conf ]; then
    cp /var/www/html/config/nginx/nginx-vhost.conf /etc/nginx/conf.d/default.conf
else

    sed -i \
        -e "s/FPM_HOST/${FPM_HOST}/g" \
        -e "s/FPM_PORT/${FPM_PORT}/g" \
        /etc/nginx/conf.d/default.conf

fi

if [ -f /var/www/html/config/nginx/nginx-vhost-ssl.conf ]; then
    cp /var/www/html/config/nginx/nginx-vhost-ssl.conf /etc/nginx/conf.d/default-ssl.conf
else

    if [ -f /etc/nginx/ssl/server.pem ] || [ -f /etc/nginx/ssl/server.key ]; then
	# Проверяем, смонтирован ли внешний SSL сертификат

	sed -i "s/\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/\/etc\/nginx\/ssl\/server.pem/g" /etc/nginx/conf.d/default-ssl.conf
	sed -i "s/\/etc\/ssl\/private\/ssl-cert-snakeoil.key/\/etc\/nginx\/ssl\/server.key/g" /etc/nginx/conf.d/default-ssl.conf

    elif [ -f /etc/letsencrypt/live/${SSL_DOMAIN}/fullchain.pem ] || [ -f /etc/letsencrypt/live/${SSL_DOMAIN}/privkey.pem ]; then
	# Проверяем, существует ли Let's Encrypt сертификат

	sed -i "s/\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/\/etc\/letsencrypt\/live\/${SSL_DOMAIN}\/fullchain.pem/g" /etc/nginx/conf.d/default-ssl.conf
	sed -i "s/\/etc\/ssl\/private\/ssl-cert-snakeoil.key/\/etc\/letsencrypt\/live\/${SSL_DOMAIN}\/privkey.pem/g" /etc/nginx/conf.d/default-ssl.conf

    fi

    sed -i \
        -e "s/FPM_HOST/${FPM_HOST}/g" \
        -e "s/FPM_PORT/${FPM_PORT}/g" \
        /etc/nginx/conf.d/default-ssl.conf

fi

if [ ! -f /etc/nginx/ssl/dhparam.pem ]; then
    openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf

exec "$@"
