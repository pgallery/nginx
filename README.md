## Описание

Это Dockerfile, позволяющие собрать простой образ для Docker с Nginx и поддержкой Let's Encrypt. Собран на основе официального образа nginx:latest.

## Репозиторий Git

Репозиторий исходных файлов данного проекта: [https://github.com/pgallery/nginx](https://github.com/pgallery/nginx)

## Репозиторий Docker Hub

Расположение образа в Docker Hub: [https://hub.docker.com/r/pgallery/nginx/](https://hub.docker.com/r/pgallery/nginx/)

## Использование Docker Hub

```
sudo docker pull pgallery/nginx
```

## Запуск

```
sudo docker run -d -p 80:80 -p 443:443 \
    -v /home/username/sitename/www/:/var/www/html/ \
    -v /home/username/sitename/logs/:/var/log/nginx/ \
    -e 'TIMEZONE=Europe/Moscow' \
    pgallery/nginx
```

По умолчанию TIMEZONE установлена Europe/Moscow.

## Поддержка Let's Encrypt

Данный образ имеет поддержку SSL сертификатов Let's Encrypt. Для установки сертификата необходимо при запуске контейнера добавить параметры:

 - **SSL_DOMAIN**: имя домена, на который будет выдан SSL сертификат
 - **SSL_EMAIL**: E-Mail администратора домена

**Оба параметра обязательны, если Вы желаете использовать Let's Encrypt**

#### Пример использования

```
sudo docker run -d \
    -e 'SSL_DOMAIN=example.com,www.example.com' \
    -e 'SSL_EMAIL=admin@example.com' \
    pgallery/nginx
```

### Установка сертификата

```
docker exec -it <CONTAINER_NAME> /usr/local/bin/letsencrypt-init
```

### Перевыпуск сертификата

```
docker exec -it <CONTAINER_NAME> /usr/local/bin/letsencrypt-renew
```

## Использование собственных конфигурационных файлов

Вы можете использовать собственные конфигурационные файлы для nginx. Для этого Вам необходимо создать их в директории **/var/www/html/config/**. При их обнаружении, Ваши конфигурационные файлы будут скопированы и заменят существующие.

### Nginx

 - **/var/www/html/config/nginx/nginx.conf** - данным файлом будет заменен /etc/nginx/nginx.conf
 - **/var/www/html/config/nginx/nginx-vhost.conf** - данным файлом будет заменен /etc/nginx/conf.d/default.conf
 - **/var/www/html/config/nginx/nginx-vhost-ssl.conf** - данным файлом будет заменен /etc/nginx/conf.d/default-ssl.conf
