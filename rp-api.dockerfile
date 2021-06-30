FROM ubuntu:18.04
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

 
RUN apt-get update \ 
    && apt-get install -y apache2 \
    && apt-get install -y --no-install-recommends gnupg apt-utils software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \ 
    && apt-get -y install curl ca-certificates \
    php7.3 php7.3-cli php7.3-curl php7.3-apcu php7.3-apcu-bc php7.3-dev libmcrypt-dev php-pear php7.3-curl \
    php7.3-json php7.3-pdo-mysql php7.3-mbstring php7.3-opcache php7.3-readline php7.3-xml php7.3-zip php7.3-bcmath php7.3-gd php7.3-mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \   
    && composer clear-cache \
    && apt-get install -y gettext-base \
    && apt-get install -y libsodium-dev php7.3-bz2 php7.3-soap php7.3-dba php7.3-gmp php7.3-intl \
    php7.3-ldap php7.3-odbc php7.3-pdo-dblib unixodbc unixodbc-dev php7.3-pdo-odbc php7.3-sqlite3 \
    php7.3-xmlrpc php7.3-common php7.3-uuid php7.3-amqp php7.3-memcached \
    php7.3-pdo-sqlite php7.3-mongodb \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor \
    && apt-get clean 
    
RUN pecl install -f uopz redis libsodium mongodb-1.8.1 mcrypt-1.0.2
RUN echo "extension=sodium.so" > /etc/php/7.3/mods-available/sodium.ini \
    && echo "extension=uopz.so" > /etc/php/7.3/mods-available/uopz.ini \
    && echo "extension=redis.so" > /etc/php/7.3/mods-available/redis.ini \
    && echo "extension=mongodb.so" > /etc/php/7.3/mods-available/mongodb.ini \
    \
    && echo "memory_limit=512M" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "post_max_size=500M" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "max_execution_time=600" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "disable_functions=getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "allow_url_fopen = On" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE" >> /etc/php/7.3/apache2/conf.d/1-myconfig.ini

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && rm /var/www/html/index.html

RUN ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log

COPY ./configs/rp-api/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./configs/rp-api/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf
WORKDIR /var/www/html
RUN a2enmod rewrite
EXPOSE 80
CMD ["/usr/bin/supervisord"]