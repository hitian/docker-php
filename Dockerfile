FROM ubuntu:16.04

#for china user.
#RUN sed -i -- 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list

RUN apt-get update -y && apt-get install -y curl build-essential libxml2-dev zlib1g-dev libcurl4-openssl-dev libjpeg-dev libpng-dev autoconf pkg-config libmemcached-dev libmcrypt-dev
RUN cd /tmp && curl -s -L -o libmcrypt-2.5.8.tar.gz https://www.dropbox.com/s/073wv8fa75pwdqu/libmcrypt-2.5.8.tar.gz?dl=1 && \
    tar zxf libmcrypt-2.5.8.tar.gz && cd libmcrypt-2.5.8 && ./configure && make && make install && \
    cd /tmp && curl -s -L -o php54.tar.gz https://secure.php.net/distributions/php-5.4.45.tar.gz && \
    tar zxf php54.tar.gz && cd php-5.4.45 && \
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
    export EXT_DIR=$(php-config --extension-dir) && \
    echo "extension_dir = $EXT_DIR" >> /opt/php/php.ini && \
    mkdir -p $EXT_DIR && \
    cd /tmp && curl -s -L -o memcache-3.0.8.tgz https://pecl.php.net/get/memcache-3.0.8.tgz && \
    tar zxf memcache-3.0.8.tgz && cd memcache-3.0.8 && \
    phpize && ./configure && make -j4 && cp modules/memcache.so $EXT_DIR && \
    touch /opt/php/conf.d/memcache.ini && echo "extension=$EXT_DIR/memcache.so" > /opt/php/conf.d/memcache.ini && \
    cd /tmp && curl -s -L -o redis-2.2.7.tar.gz https://pecl.php.net/get/redis-2.2.7.tgz && \
    tar zxf redis-2.2.7.tar.gz && cd redis-2.2.7/ && phpize && \
    ./configure && make -j4 && cp modules/redis.so $EXT_DIR && \
    touch /opt/php/conf.d/redis.ini && echo "extension=$EXT_DIR/redis.so" >> /opt/php/conf.d/redis.ini && \
    cd /tmp && curl -s -L -o memcached-2.2.0.tgz https://pecl.php.net/get/memcached-2.2.0.tgz && \
    tar zxf memcached-2.2.0.tgz && cd memcached-2.2.0 && \
    phpize && ./configure  && make -j4 && cp modules/memcached.so $EXT_DIR && \
    touch /opt/php/conf.d/memcached.ini && echo "extension=$EXT_DIR/memcached.so" > /opt/php/conf.d/memcached.ini && \
    cd /tmp && curl -s -L -o xdebug-2.4.1.tgz https://xdebug.org/files/xdebug-2.4.1.tgz && \
    tar xzvf xdebug-2.4.1.tgz && cd xdebug-2.4.1 && \
    phpize && ./configure --enable-xdebug  && make -j4 && \
    cp modules/xdebug.so $EXT_DIR && touch /opt/php/conf.d/xdebug.ini && \
    echo "zend_extension=$EXT_DIR/xdebug.so" > /opt/php/conf.d/xdebug.ini && \
    rm -rf /tmp/*

ENV PATH /opt/bin:$PATH
VOLUME [ "/app" ]
WORKDIR /app
CMD ["php", "-v"]