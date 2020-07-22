FROM ubuntu:18.04
ENV OS_LOCALE="en_US.UTF-8"
SHELL ["/bin/bash", "-c"] 
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

RUN mkdir -p $APACHE_RUN_DIR 

RUN	BUILD_DEPS='software-properties-common' \
    && dpkg-reconfigure locales \
    && apt-get install --no-install-recommends -y $BUILD_DEPS \
    && apt-get install -y curl apache2 \
    && cp /dev/null ${APACHE_CONF_DIR}/conf-available/other-vhosts-access-log.conf 

RUN apt-get purge -y --auto-remove $BUILD_DEPS \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
    && rm /var/www/html/index.html \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log 

COPY ./configs/000-default.conf ${APACHE_CONF_DIR}/sites-enabled/000-default.conf
EXPOSE 80
WORKDIR /var/www/html
RUN a2enmod rewrite
RUN service apache2 restart

CMD ["apache2", "-D", "FOREGROUND"]