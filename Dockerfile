FROM php:7.4-fpm-buster

WORKDIR /root

# Setup filesystem, user accounts, etc...
RUN \
    useradd -Um application -u 1000 -s /bin/bash \
    && echo "alias ll='ls -alh'" >> ~/.bashrc \
    && ln -sf /proc/1/fd/1 /docker.stdout \
    && ln -sf /proc/1/fd/2 /docker.stderr \
    && mkdir -p /var/log/supervisor

# # Install Packages
ARG DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        apngopt \
        apt-transport-https \
        ca-certificates \
        cron \
        debconf-doc \
        dnsutils \
        gcc \
        gnupg \
        jpegoptim \
        libbz2-dev \
        libc-client-dev \
        libc-client2007e-dev \
        libfreetype6-dev \
        libgd-dev \
        libicu-dev \
        libjpeg-turbo-progs \
        libjpeg62-turbo-dev \
        libkrb5-dev \
        libmagick++-dev \
        libmemcached-dev \
        libpcre3-dev \
        libperl-dev \
        libpng-dev \
        libpng16-16 \
        libpq-dev \
        libpq5 \
        librabbitmq-dev \
        librabbitmq4 \
        libsasl2-modules \
        libssl-dev \
        libvips-dev \
        libvips42 \
        libwebp-dev \
        libxml2-dev \
        libxslt-dev \
        libxslt1-dev \
        libxslt1.1 \
        libzip-dev \
        libzip4 \
        locales \
        lsof \
        mariadb-client \
        nano \
        netcat \
        optipng \
        pngcrush \
        pngnq \
        pngquant \
        redis-tools \
        supervisor \
        wget \
        zlib1g \
        zlib1g-dev \
        zlibc \
        nginx \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer --version 2.1.5 \
    && docker-php-ext-configure gd \
    && docker-php-ext-configure intl \ 
    && docker-php-ext-install \
        bcmath \
        intl \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip \
        gd \
        opcache \
    && docker-php-source delete \
    && rm -f /tmp/.apt-update \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && find /tmp/ -mindepth 1 -delete \
    && rm -rf /root/.cache \
    && rm -rf /tmp/pear

# Configure PHP and FPM
COPY devops/php/config/php.ini $PHP_INI_DIR/php.ini
COPY devops/php/config/php-fpm.conf /usr/local/etc/php-fpm.d/zzz_tgcbaseimage_php.conf

# Configure NGINX
# COPY devops/nginx/default.conf /etc/nginx/sites-enabled/default.conf


# # Configure supervisord
COPY devops/supervisor /etc/supervisor/conf.d
RUN \
    rm -f /etc/supervisor/supervisord.conf \
    && ln -s /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 80
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

