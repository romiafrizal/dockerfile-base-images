FROM ubuntu:18.04
ENV OS_LOCALE="en_US.UTF-8"
RUN apt-get update && apt-get install -y locales && locale-gen ${OS_LOCALE}
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    APACHE_CONF_DIR=/etc/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2

RUN apt-get update 
RUN apt-get install -y --no-install-recommends gnupg apt-utils apache2 \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update     && apt-get -y install curl ca-certificates unzip software-properties-common \
    php7.4 php7.4-cli php7.4-curl php7.4-apcu php7.4-apcu-bc php7.4-dev libmcrypt-dev php-pear php7.4-curl \
    php7.4-json php7.4-pdo-mysql php7.4-mbstring php7.4-opcache php7.4-readline php7.4-xml php7.4-zip php7.4-bcmath php7.4-gd php7.4-mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \   
    && composer clear-cache \
    && apt-get install -y gettext-base \
    && apt-get clean  \
    && apt-get install -y libsodium-dev php7.4-bz2 php7.4-soap php7.4-dba php7.4-gmp php7.4-intl \
    php7.4-ldap php7.4-odbc php7.4-pdo-dblib unixodbc unixodbc-dev php7.4-pdo-odbc php7.4-sqlite3 \
    php7.4-xmlrpc php7.4-common php7.4-uuid php7.4-amqp php7.4-memcached \
    php7.4-pdo-sqlite php7.4-mongodb \
    && apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor
    
RUN pecl install -f uopz redis libsodium mongodb-1.8.1 mcrypt-1.0.3
RUN echo "extension=sodium.so" > /etc/php/7.4/mods-available/sodium.ini \
    && echo "extension=uopz.so" > /etc/php/7.4/mods-available/uopz.ini \
    && echo "extension=redis.so" > /etc/php/7.4/mods-available/redis.ini \
    && echo "extension=mongodb.so" > /etc/php/7.4/mods-available/mongodb.ini \
    \
    && echo "memory_limit=512M" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "post_max_size=500M" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "max_execution_time=600" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && rm /var/www/html/index.html

RUN ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log

COPY ./configs/000-default.conf ${APACHE_CONF_DIR}/sites-enabled/000-default.conf
COPY ./configs/php74-apache/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf
WORKDIR /var/www/html
RUN a2enmod rewrite
EXPOSE 80
CMD ["/usr/bin/supervisord"]