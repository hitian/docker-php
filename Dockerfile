FROM ubuntu:latest
MAINTAINER tian <t@hitian.info>

#for china user.
#RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list
RUN	apt-get update -y && apt-get upgrade -y && \
	apt-get install -y build-essential curl libxml2-dev autoconf zlib1g-dev libcurl4-openssl-dev \
	    libjpeg9-dev libpng-dev libfreetype6-dev
RUN cd /opt && curl -L -o php54.tar.gz https://secure.php.net/distributions/php-5.4.45.tar.gz && \
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
    cp php.ini-development /etc/php.ini && \
    echo 'extension_dir = "/usr/lib/php/modules"' >> /etc/php.ini

RUN mkdir -p $(php-config --extension-dir)

RUN cd /opt && curl -L -o memcache-2.2.7.tgz https://pecl.php.net/get/memcache-2.2.7.tgz && \
    tar zxvf memcache-2.2.7.tgz && cd memcache-2.2.7 && \
    phpize && ./configure && make -j4 && cp modules/memcache.so $(php-config --extension-dir) && \
    touch /etc/php/conf.d/memcached.ini && echo 'extension=memcache.so' > /etc/php/conf.d/memcached.ini

RUN cd /opt && curl -L -o phpredis.tar.gz https://github.com/phpredis/phpredis/archive/3.1.3.tar.gz && \
    tar zxvf phpredis.tar.gz && cd phpredis-3.1.3/ && phpize && \
    ./configure && make -j4 && cp modules/redis.so $(php-config --extension-dir) && \
    touch /etc/php/conf.d/redis.ini && echo 'extension=redis.so' >> /etc/php/conf.d/redis.ini