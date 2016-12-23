FROM alpine:edge

MAINTAINER Kai Suzuki <s_kai@wh-plus.com>

RUN apk update && apk upgrade && \
    apk add nginx && \
    mkdir /web && \
    rm -rf /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf

ENV NGINX_PATH_PREFIX=/var/www/unison

EXPOSE 80 443

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
