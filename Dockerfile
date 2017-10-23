FROM nginx:latest

LABEL maintainer="Ruzhentsev Alexandr <git@pgallery.ru>"
LABEL version="1.0 beta"
LABEL description="Docker image Nginx for pGallery"

RUN apt-get update && apt-get install -y wget ca-certificates apt-transport-https \
    && apt-get update && apt-get -y upgrade \
    && apt-get install -y ssl-cert supervisor python-certbot-nginx procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

COPY config/nginx.conf 			/etc/nginx/nginx.conf
COPY config/nginx-vhost.conf 		/etc/nginx/conf.d/default.conf
COPY config/nginx-vhost-ssl.conf 	/etc/nginx/conf.d/default-ssl.conf
COPY config/supervisord.conf 		/etc/supervisord.conf
COPY scripts/ 				/usr/local/bin/

RUN chmod 755 /usr/local/bin/letsencrypt-init \
    && chmod 755 /usr/local/bin/letsencrypt-renew \
    && chmod 755 /usr/local/bin/docker-entrypoint.sh

VOLUME /var/www/html

EXPOSE 80 443

CMD ["/usr/local/bin/docker-entrypoint.sh"]
