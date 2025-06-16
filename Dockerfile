FROM dunglas/frankenphp

ARG USER=www-data

ENV WORKERS=1
ENV MAX_REQUESTS=1

RUN install-php-extensions \
    pcntl \
    pdo_mysql \
    mbstring \
    exif \
    bcmath \
    gd \
    opcache \
    redis \
    zip

RUN apt-get update && apt-get install -y \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN \
    # Use "adduser -D ${USER}" for alpine based distros
    useradd -D ${USER}; \
    # Add additional capability to bind to port 80 and 443
    setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp; \
    # Give write access to /data/caddy and /config/caddy
    chown -R ${USER}:${USER} /data/caddy && chown -R ${USER}:${USER} /config/caddy

USER ${USER}

EXPOSE 8000

CMD ["sh", "-c", "exec php artisan octane:frankenphp --workers=${WORKERS} --max-requests=${MAX_REQUESTS}"]
