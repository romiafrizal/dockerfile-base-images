FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update 
RUN apt-get install -y --no-install-recommends gnupg apt-utils nginx \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update     && apt-get -y install curl ca-certificates unzip software-properties-common \
    php7.3 php7.3-fpm php7.3-cli php7.3-curl php7.3-apcu php7.3-apcu-bc php7.3-dev libmcrypt-dev php-pear php7.3-curl \
    php7.3-json php7.3-pdo-mysql php7.3-mbstring php7.3-opcache php7.3-readline php7.3-xml php7.3-zip php7.3-bcmath php7.3-gd php7.3-mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \   
    && composer clear-cache \
    && apt-get install -y gettext-base \
    && apt-get clean  \
    && apt-get install -y libsodium-dev php7.3-bz2 php7.3-soap php7.3-dba php7.3-gmp php7.3-intl \
    php7.3-ldap php7.3-odbc php7.3-pdo-dblib unixodbc unixodbc-dev php7.3-pdo-odbc php7.3-sqlite3 \
    php7.3-xmlrpc php7.3-common php7.3-uuid php7.3-amqp php7.3-memcached \
    php7.3-pdo-sqlite php7.3-mongodb \
    && apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor
    
RUN pecl install -f uopz redis libsodium mongodb-1.8.1 mcrypt-1.0.2
RUN echo "extension=sodium.so" > /etc/php/7.3/mods-available/sodium.ini \
    && echo "extension=uopz.so" > /etc/php/7.3/mods-available/uopz.ini \
    && echo "extension=redis.so" > /etc/php/7.3/mods-available/redis.ini \
    && echo "extension=mongodb.so" > /etc/php/7.3/mods-available/mongodb.ini \
    \
    && echo "memory_limit=512M" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "max_file_uploads=1000" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "post_max_size=500M" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "max_execution_time=600" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "disable_functions=getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "allow_url_fopen = On" >> /etc/php/7.3/fpm/conf.d/adab.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE" >> /etc/php/7.3/fpm/conf.d/adab.ini

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && rm /var/www/html/index.nginx-debian.html

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./configs/php73-backend/default /etc/nginx/sites-enabled/default
COPY ./configs/php73-backend/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf
WORKDIR /var/www/html
EXPOSE 80
CMD ["/usr/bin/supervisord"]