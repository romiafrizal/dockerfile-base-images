FROM romiafrizal/adab4be-lumen:v1.0 
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update 
RUN apt-get install -y  libsodium-dev php7.3-xdebug php7.3-bz2 php7.3-soap php7.3-dba php7.3-gmp php7.3-intl \
    php7.3-ldap php7.3-odbc php7.3-pdo-dblib unixodbc unixodbc-dev php7.3-pdo-odbc php7.3-sqlite3 php7.3-phpdbg \
    php7.3-xmlrpc php7.3-common php7.3-uuid php7.3-amqp php7.3-memcached \
    php7.3-pdo-sqlite
RUN pecl install -f uopz redis libsodium
RUN echo "extension=sodium.so" > /etc/php/7.3/mods-available/sodium.ini \
    && echo "extension=uopz.so" > /etc/php/7.3/mods-available/uopz.ini \
    && echo "extension=redis.so" > /etc/php/7.3/mods-available/redis.ini \
    \
    && echo "memory_limit=512M" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "post_max_size=500M" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "max_execution_time=600" >> /etc/php/7.3/fpm/conf.d/adab.ini

RUN rm -rf /var/lib/apt/lists/*
EXPOSE 80
CMD ["/usr/bin/supervisord"]
