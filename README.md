# php 5.4.45 on ubuntu 16.04

php-fpm with nginx

## modules

* memcache-3.0.8
* redis-2.2.7
* msgpack-0.5.7
* igbinary-1.2.1
* memcached-2.2.0
* xdebug-2.4.1

## usage

```bash
docker run -p 80:80 -p 443:443 -v /www/root:/app -d hitian/php-54
```