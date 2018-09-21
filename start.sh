#!/bin/bash

#start php-fpm
/etc/init.d/php-fpm start

#start nginx
nginx -g 'daemon off;'