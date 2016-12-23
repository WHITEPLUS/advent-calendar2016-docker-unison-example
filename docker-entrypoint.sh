#!/bin/sh
/usr/sbin/nginx \
 -g "daemon off;" \
 -p ${NGINX_PATH_PREFIX}
