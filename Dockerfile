FROM php:7.1.3-apache

MAINTAINER rodwin lising <rodwinlising@gmail.com>

# install the PHP extensions we need
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        git \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mbstring zip mysqli pdo_mysql\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

#install nodejs
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash

RUN apt-get install nodejs

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && echo "alias composer='/usr/local/bin/composer.phar'" >> ~/.bashrc

# Source the bash
RUN . ~/.bashrc

# PHP extensions for 16.1
RUN apt-get -y install libtidy-dev \
    && docker-php-ext-install tidy \
    && docker-php-ext-install bcmath

RUN a2enmod rewrite

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY config/php.ini /usr/local/etc/php/

COPY libs/ /libs/

#kafka library and client needed
RUN cd /libs/librdkafka && ./configure
RUN cd /libs/librdkafka && make && make install

RUN cd /libs/php-rdkafka && phpize && ./configure   
RUN cd /libs/php-rdkafka && make && make install

# COPY src/ /var/www/html/
# Volume configuration
VOLUME ["/var/www/html"]