FROM alpine:latest
MAINTAINER tian <t@hitian.info>

#for china user.
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk update && apk add --no-cache build-base curl libxml2-dev autoconf zlib-dev \ 
    libcurl curl-dev libjpeg libpng-dev freetype pkgconf-dev libmemcached-dev cyrus-sasl-dev && \
    cd /tmp && curl -L -o php54.tar.gz https://secure.php.net/distributions/php-5.4.45.tar.gz && \
    tar zxvf php54.tar.gz && cd php-5.4.45 && \
    ./configure \
    --prefix=/usr \
    --with-config-file-path=/etc/php \
    --with-config-file-scan-dir=/etc/php/conf.d \
    --enable-bcmath \
    --enable-calendar \
    --enable-dba \
    --enable-exif \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mbregex \
    --enable-mbstring \
    --enable-shmop \
    --enable-soap \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-wddx \
    --enable-zip \
    --with-gd \
    --with-mhash \
    --with-zlib=/usr \
    --enable-fpm \
    --with-curl \
    --with-mysqli=mysqlnd \
    --with-mysql=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    && make -j4 && make install && \
    mkdir -p /usr/lib/php/modules && \
    mkdir -p /etc/php/conf.d && \
    cp php.ini-development /etc/php/php.ini && \
    echo 'extension_dir = "/usr/lib/php/modules"' >> /etc/php.ini && \
    mkdir -p $(php-config --extension-dir) && \
    cd /tmp && curl -L -o memcache-2.2.7.tgz https://pecl.php.net/get/memcache-2.2.7.tgz && \
    tar zxvf memcache-2.2.7.tgz && cd memcache-2.2.7 && \
    phpize && ./configure && make -j4 && cp modules/memcache.so $(php-config --extension-dir) && \
    touch /etc/php/conf.d/memcache.ini && echo 'extension=memcache.so' > /etc/php/conf.d/memcache.ini && \
    cd /tmp && curl -L -o phpredis.tar.gz https://github.com/phpredis/phpredis/archive/3.1.3.tar.gz && \
    tar zxvf phpredis.tar.gz && cd phpredis-3.1.3/ && phpize && \
    ./configure && make -j4 && cp modules/redis.so $(php-config --extension-dir) && \
    touch /etc/php/conf.d/redis.ini && echo 'extension=redis.so' >> /etc/php/conf.d/redis.ini && \
    cd /tmp && curl -L -o memcached-2.2.0.tgz https://pecl.php.net/get/memcached-2.2.0.tgz && \
    tar zxvf memcached-2.2.0.tgz && cd memcached-2.2.0 && \
    phpize && ./configure  && make -j4 && cp modules/memcached.so $(php-config --extension-dir) && \
    touch /etc/php/conf.d/memcached.ini && echo 'extension=memcached.so' > /etc/php/conf.d/memcached.ini && \
    cd /tmp && curl -L -o xdebug-2.4.1.tgz https://xdebug.org/files/xdebug-2.4.1.tgz && \
    tar xzvf xdebug-2.4.1.tgz && cd xdebug-2.4.1 && \
    phpize && ./configure --enable-xdebug  && make -j4 && \
    cp modules/xdebug.so /usr/lib/ && touch /etc/php/conf.d/xdebug.ini && \
    echo 'zend_extension=/usr/lib/xdebug.so' > /etc/php/conf.d/xdebug.ini && \
    rm -rf /tmp/* && apk del build-base autoconf

WORKDIR /app
EXPOSE 8089
ENTRYPOINT ["php", "-S", "0.0.0.0:8089"]
