FROM ubuntu:22.04
ENV OS_LOCALE="en_US.UTF-8"
RUN apt-get update && apt-get install -y locales && locale-gen ${OS_LOCALE}
ENV DEBIAN_FRONTEND=noninteractive \
    APP_DIR=/var/www/html \
    APM_SERVER_URL="http://localhost:8200" \
    APM_SECRET_TOKEN="" \
    APM_SERVICE_NAME="APM" \
    LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    APACHE_CONF_DIR=/etc/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends curl gnupg apt-utils apache2 supervisor \
    software-properties-common ca-certificates lsb-release apt-transport-https \
    && add-apt-repository ppa:ondrej/php \
    && \
    apt-get install -y php7.3 \
    php7.3-bcmath \
    php7.3-bz2 \
    php7.3-curl \
    php7.3-dom \
    php7.3-enchant \
    php7.3-gd \
    php7.3-gmp \
    php7.3-imagick \
    php7.3-intl \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-mysqli \
    php7.3-mysqlnd \
    php7.3-pdo-mysql \
    php7.3-pdo-pgsql \
    php7.3-pgsql \ 
    php7.3-SimpleXML \
    php7.3-tidy \
    php7.3-wddx \
    php7.3-xml \
    php7.3-xmlreader \
    php7.3-xmlwriter \
    php7.3-xsl \
    php7.3-zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \   
    && composer clear-cache \
    && mkdir -p /var/log/supervisor \
    && curl -OL https://github.com/elastic/apm-agent-php/releases/download/v1.5.2/apm-agent-php_1.5.2_all.deb \
    && dpkg -i apm-agent-php_1.5.2_all.deb \
    && rm -f apm-agent-php_1.5.2_all.deb    
    
RUN echo "memory_limit=512M" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "post_max_size=500M" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "max_execution_time=600" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "disable_functions=getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "allow_url_fopen = On" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && echo "error_reporting = 0" >> /etc/php/7.3/apache2/conf.d/1-ktvconfig.ini \
    && a2enmod rewrite headers \
    && ln -sf /dev/stderr ${APACHE_LOG_DIR}/error.log

COPY ./conf/php73-apache/000-default.conf ${APACHE_CONF_DIR}/sites-enabled/000-default.conf
COPY ./conf/php73-apache/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    /usr/share/man/?? /usr/share/man/??_* \
    && rm /var/www/html/index.html

WORKDIR /var/www/html
EXPOSE 80
CMD ["supervisord"]