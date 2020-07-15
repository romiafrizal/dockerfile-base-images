FROM php:7.3.20-apache
WORKDIR /var/www/html/
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        libzip-dev \
        libxslt-dev \
        zip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libgd-dev \
        libpng-dev \
        libmcrypt-dev \
        libmongoc-1.0-0 \
        && rm -rf /var/lib/apt/lists/*

RUN pecl install mongodb \
    && pecl install mcrypt-1.0.2 \
    && echo "extension=mongodb.so" > $PHP_INI_DIR/conf.d/mongodb.ini \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) bcmath \
    mysqli \
    zip \
    calendar \
    pcntl \
    shmop \
    sockets \
    xsl \
    gd 
RUN docker-php-ext-install -j$(nproc) xmlrpc \
    soap \
    pdo_mysql


RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
RUN composer --version && php -m
RUN a2enmod rewrite 
EXPOSE 80
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]