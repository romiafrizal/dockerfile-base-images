FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends gnupg apt-utils apache2 \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update     && apt-get -y install curl ca-certificates unzip software-properties-common \
    php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-apcu php7.2-apcu-bc php7.2-dev libmcrypt-dev php-pear php7.2-curl php7.2-imagick php7.2-wddx \
    php7.2-msgpack php7.2-igbinary php7.2-imap php7.2-mysqli php7.2-tidy php7.2-pspell php7.2-shmop php7.2-gettext  php7.2-xsl hp7.2-sockets \
    php7.2-calendar php7.2-gmp \
    php7.2-json php7.2-pdo-mysql php7.2-mbstring php7.2-opcache php7.2-readline php7.2-xml php7.2-zip php7.2-bcmath php7.2-gd php7.2-mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \   
    && composer clear-cache \
    && apt-get install -y gettext-base \
    && apt-get clean  \
    && apt-get install -y libsodium-dev php7.2-bz2 php7.2-soap php7.2-dba php7.2-gmp php7.2-intl \
    php7.2-ldap php7.2-odbc php7.2-pdo-dblib unixodbc unixodbc-dev php7.2-pdo-odbc php7.2-sqlite3 \
    php7.2-xmlrpc php7.2-common php7.2-uuid php7.2-amqp php7.2-memcached \
    php7.2-pdo-sqlite php7.2-mongodb \
    && apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor 

RUN pecl install -f uopz redis libsodium mongodb-1.8.1 mcrypt-1.0.3
RUN echo "extension=sodium.so" > /etc/php/7.2/mods-available/sodium.ini \
    && echo "extension=uopz.so" > /etc/php/7.2/mods-available/uopz.ini \
    && echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini \
    && echo "extension=mongodb.so" > /etc/php/7.2/mods-available/mongodb.ini \
    \
    && echo "memory_limit=512M" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "upload_max_filesize=512M" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "post_max_size=512M" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "max_execution_time=600" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "disable_functions=getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "allow_url_fopen = On" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE" >> /etc/php/7.2/apache2/conf.d/1-myconfig.ini

RUN apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log
# Cleanup
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && rm /var/www/html/index.html
RUN a2enmod rewrite && apachectl restart
COPY ./configs/yii2-ubuntu/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./configs/yii2-ubuntu/000-default.conf /etc/apache2/sites-enabled/000-default.conf
WORKDIR /var/www/html
EXPOSE 80
CMD ["/usr/bin/supervisord"]