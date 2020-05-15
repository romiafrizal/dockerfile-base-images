FROM yiisoftware/yii2-php:7.2-apache
ENV DEBIAN_FRONTEND=noninteractive
#bz
RUN apt-get update \
    && apt-get install -y libbz2-dev \
    && docker-php-ext-install -j$(nproc) bz2 

# memcached
RUN apt-get install -y --no-install-recommends \
	libmemcached-dev \
	libmemcached11 

#Math
RUN apt-get install -y libgmp-dev \
	&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
	&& docker-php-ext-install -j$(nproc) \
		gmp \
		bcmath
#Other 
RUN apt-get install -y --no-install-recommends \
    libtidy-dev libxslt-dev libpspell-dev 

#Other
RUN docker-php-ext-install -j$(nproc) calendar sysvmsg sysvsem sysvshm \
    gettext tidy mysqli pspell shmop sockets xmlrpc xsl

# imap
RUN apt-get install -y libc-client-dev libkrb5-dev
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Install php-igbinary
ENV EXT_REDIS_VERSION=4.3.0 EXT_IGBINARY_VERSION=3.0.1
RUN docker-php-source extract \
    # igbinary
    && mkdir -p /usr/src/php/ext/igbinary \
    &&  curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install igbinary \
    # redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis 
# PECL #Memcached
RUN pecl install \
	memcached-3.0.4 msgpack-2.0.2 \
    && docker-php-ext-enable memcached

# Install php-wddx
RUN docker-php-ext-configure wddx \
    && docker-php-ext-install wddx

RUN docker-php-ext-enable \
    msgpack
#bcmath
#bz2
#calendar
#gettext
# gmp
#igbinary
#imap
# memcache
#msgpack
#mysqli
#pcntl
#pspell
#recode
#redis
#shmop
#sockets
#sysvmsg
#sysvsem
#sysvshm
#tidy
#wddx
#xmlrpc
#xsl
 
# Cleanup
RUN docker-php-source delete
CMD ["apache2-foreground"]
