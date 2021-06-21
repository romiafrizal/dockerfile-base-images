FROM ubuntu:20.04
ENV OS_LOCALE="en_US.UTF-8"
RUN apt update && apt install -y locales && locale-gen ${OS_LOCALE}
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

RUN apt update 
RUN apt install -y --no-install-recommends gnupg apt-utils apache2 \
    && apt update \
    && apt -y install curl ca-certificates unzip software-properties-common \
    php php-cli php-curl php-apcu php-apcu-bc php-dev libmcrypt-dev php-pear php-curl \
    php-json php-pdo-mysql php-mbstring php-opcache php-readline php-xml php-zip php-bcmath php-gd php-mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \   
    && composer clear-cache \
    && apt install -y gettext-base \
    && apt install -y libsodium-dev php-bz2 php-soap php-dba php-gmp php-intl \
    php-ldap php-odbc php-pdo-dblib unixodbc unixodbc-dev php-pdo-odbc php-sqlite3 \
    php-xmlrpc php-common php-uuid php-amqp php-memcached \
    php-pdo-sqlite php-mongodb \
    && apt update \
    && apt install -y supervisor \
    && mkdir -p /var/log/supervisor \
    && apt clean
    
RUN mkdir -p /tmp/pear/cache \
    && pecl install -f uopz redis libsodium mongodb-1.8.1 mcrypt-1.0.3
RUN echo "extension=sodium.so" > /etc/php/7.4/mods-available/sodium.ini \
    && echo "extension=uopz.so" > /etc/php/7.4/mods-available/uopz.ini \
    && echo "extension=redis.so" > /etc/php/7.4/mods-available/redis.ini \
    && echo "extension=mongodb.so" > /etc/php/7.4/mods-available/mongodb.ini \
    \
    && echo "memory_limit=512M" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "post_max_size=500M" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "max_execution_time=600" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "disable_functions=getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "allow_url_fopen = On" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE" >> /etc/php/7.4/apache2/conf.d/1-myconfig.ini

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && rm /var/www/html/index.html

RUN ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log

COPY ./configs/rp-reporting/000-default.conf ${APACHE_CONF_DIR}/sites-enabled/000-default.conf
COPY ./configs/rp-reporting/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf
WORKDIR /var/www/html
RUN a2enmod rewrite
EXPOSE 80
CMD ["/usr/bin/supervisord"]