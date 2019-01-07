FROM ubuntu:16.04

#for china user.
#RUN sed -i -- 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list
ENV PHP_VERSION 5.6.39

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl build-essential libxml2-dev zlib1g-dev libcurl4-openssl-dev libjpeg-dev libpng-dev autoconf pkg-config libmemcached-dev libmcrypt-dev nginx
COPY php-nginx.conf /etc/nginx/sites-available/default
COPY start.sh /start.sh
ENV PATH="/opt/bin:${PATH}"
RUN cd /tmp && curl -s -L -o libmcrypt-2.5.8.tar.gz https://www.dropbox.com/s/073wv8fa75pwdqu/libmcrypt-2.5.8.tar.gz?dl=1 && \
    tar zxf libmcrypt-2.5.8.tar.gz && cd libmcrypt-2.5.8 && ./configure && make && make install && rm -rf /tmp/*
RUN cd /tmp && curl -s -L -o php-${PHP_VERSION}.tar.gz https://secure.php.net/distributions/php-${PHP_VERSION}.tar.gz && \
    tar zxf php-${PHP_VERSION}.tar.gz && cd php-${PHP_VERSION} && \
    ./configure \
    --prefix=/opt \
    --with-config-file-path=/opt/php \
    --with-config-file-scan-dir=/opt/php/conf.d \
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
    --with-mcrypt \
    --with-pdo-mysql=mysqlnd  && \
    make -j4 && make install && \
    mkdir -p /opt/php/modules && \
    mkdir -p /opt/php/conf.d && export PATH=$PATH:/opt/bin && \
    cp php.ini-development /opt/php/php.ini && \
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && \
    cp sapi/fpm/php-fpm.conf /opt/etc/php-fpm.conf && \
    chmod 755 /etc/init.d/php-fpm && addgroup nobody && \
    export EXT_DIR=$(php-config --extension-dir) && \
    echo "extension_dir = $EXT_DIR" >> /opt/php/php.ini && \
    mkdir -p $EXT_DIR && rm -rf /tmp/*
RUN cd /tmp && curl -s -L -o memcache-3.0.8.tgz https://pecl.php.net/get/memcache-3.0.8.tgz && \
    tar zxf memcache-3.0.8.tgz && cd memcache-3.0.8 && \
    phpize && ./configure && make -j4 && make install && \
    touch /opt/php/conf.d/memcache.ini && echo "extension=memcache.so" > /opt/php/conf.d/memcache.ini && \
    cd /tmp && curl -s -L -o redis-2.2.8.tar.gz https://pecl.php.net/get/redis-2.2.8.tgz && \
    tar zxf redis-2.2.8.tar.gz && cd redis-2.2.8/ && phpize && \
    ./configure && make -j4 && make install && \
    touch /opt/php/conf.d/redis.ini && echo "extension=redis.so" >> /opt/php/conf.d/redis.ini && \
    cd /tmp && curl -s -L -o msgpack-0.5.7.tgz https://pecl.php.net/get/msgpack-0.5.7.tgz && \
    tar zxf msgpack-0.5.7.tgz && cd msgpack-0.5.7/ && phpize && \
    ./configure --with-msgpack && make -j4 && make install && \
    touch /opt/php/conf.d/msgpack.ini && echo "extension=msgpack.so" >> /opt/php/conf.d/msgpack.ini && \
    cd /tmp && curl -s -L -o igbinary-1.2.1.tgz https://pecl.php.net/get/igbinary-1.2.1.tgz && \
    tar zxf igbinary-1.2.1.tgz && cd igbinary-1.2.1/ && phpize && \
    ./configure --enable-igbinary && make -j4 && make install && \
    touch /opt/php/conf.d/igbinary.ini && echo "extension=igbinary.so" >> /opt/php/conf.d/igbinary.ini && \
    cd /tmp && curl -s -L -o memcached-2.2.0.tgz https://pecl.php.net/get/memcached-2.2.0.tgz && \
    tar zxf memcached-2.2.0.tgz && cd memcached-2.2.0 && \
    phpize && ./configure --enable-memcached --enable-memcached-igbinary --enable-memcached-json \
    --enable-memcached-msgpack --includedir=/tmp/igbinary-1.2.1/:/tmp/msgpack-0.5.7/ && \
    make -j4 && make install && \
    touch /opt/php/conf.d/memcached.ini && echo "extension=memcached.so" > /opt/php/conf.d/memcached.ini && \
    cd /tmp && curl -s -L -o xdebug-2.4.1.tgz https://xdebug.org/files/xdebug-2.4.1.tgz && \
    tar xzvf xdebug-2.4.1.tgz && cd xdebug-2.4.1 && \
    phpize && ./configure --enable-xdebug  && make -j4 && \
    make install && touch /opt/php/conf.d/xdebug.ini && \
    echo "zend_extension=xdebug.so" > /opt/php/conf.d/xdebug.ini && \
    rm -rf /tmp/*

ENV PATH /opt/bin:/opt/sbin:$PATH
WORKDIR /app
EXPOSE 80 443
CMD ["bash", "/start.sh"]