FROM dunglas/frankenphp:1-php8.5

ARG USER=www-data

ENV WORKERS=2
ENV MAX_REQUESTS=1000
ENV PHP_MEMORY_LIMIT=512M
ENV XDG_CONFIG_HOME=/config

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
     && printf '%s\n' \
    'memory_limit=${PHP_MEMORY_LIMIT}' \
    'expose_php=Off' \
    'opcache.memory_consumption=256' \
    'opcache.interned_strings_buffer=32' \
    'opcache.max_accelerated_files=50000' \
    'opcache.validate_timestamps=0' \
    > "$PHP_INI_DIR/conf.d/zz-base.ini"
    && install-php-extensions \
    pcntl \
    pdo_mysql \
    mbstring \
    exif \
    bcmath \
    gd \
    opcache \
    redis \
    zip \
    intl

RUN apt-get update && apt-get install -y \
    mariadb-client nano unzip \
    && rm -rf /var/lib/apt/lists/*

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp && \
    mkdir -p /data/caddy /config/caddy /config/psysh && \
    chown -R ${USER}:${USER} /data/caddy /config/caddy /config/psysh

USER ${USER}

EXPOSE 8000

CMD ["sh", "-c", "exec php artisan octane:frankenphp --workers=${WORKERS} --max-requests=${MAX_REQUESTS}"]
