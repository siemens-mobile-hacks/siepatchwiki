FROM php:8.3-fpm-alpine3.20
RUN apk add php83-sqlite3 git diffutils
RUN mkdir /data && chmod 777 /data
RUN set -ex \
    && apk --no-cache add icu-dev libjpeg-turbo-dev libpng-dev freetype-dev zlib-dev \
    && apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j"$(nproc)" intl gd \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .build-deps
CMD ["php-fpm"]
