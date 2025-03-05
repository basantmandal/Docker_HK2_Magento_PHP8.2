FROM php:8.2-fpm-bullseye

LABEL MAINTAINER="BasantMandal <support@hashtagkitto.co.in>"

USER root

# Set PHP Environment Variables
ENV PHP_MEMORY_LIMIT 2048M
ENV PHP_MAX_EXECUTION_TIME 60
ENV PHP_UPLOAD_MAX_FILESIZE 50M
ENV PHP_POST_MAX_SIZE 50MM

# Other Environment Variables
ENV TZ=Asia/Kolkata
ARG CUSTOM_PHP_VERSION=8.2
ENV CUSTOM_PHP_INI_PATH=/usr/local/etc/php/php.ini-development
ENV CUSTOM_PHP_INI_DIR==/usr/local/etc/php

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cron \
    curl \
    g++ \
    git \
    iputils-ping \ 
    jpegoptim optipng pngquant gifsicle \
    libbz2-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmariadb-dev  \
    libmcrypt-dev \
    libonig-dev \
    libpng-dev \
    libsodium-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \ 
    locales \
    lsof \
    nano \
    sendmail \
    software-properties-common \
    sqlite3 \
    unzip \
    wget \
    zip \
    zlib1g-dev

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install JDK-15
RUN apt-get install -y openjdk-11-jdk 
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME

# Install GD
RUN docker-php-ext-configure intl 
RUN docker-php-ext-install pcntl intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install Magento Required Extensions
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install calendar 
RUN docker-php-ext-install curl 
RUN docker-php-ext-install exif 
RUN docker-php-ext-install mysqli 
RUN docker-php-ext-install opcache 
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_sqlite 
RUN docker-php-ext-install soap 
RUN docker-php-ext-install sockets 
RUN docker-php-ext-install xsl 
RUN docker-php-ext-install zip 
RUN docker-php-ext-install -j$(nproc) intl

# Install Redis
RUN pecl install redis-6.1.0 && docker-php-ext-enable redis

# IonCube Loader
ARG IONCUBE_PATH=./ioncube/2025_01_30/ioncube_loaders_lin_x86-64.tar.gz
COPY $IONCUBE_PATH /tmp/
RUN tar xzf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /usr/local
RUN (echo 'zend_extension=ioncube_loader_lin_${CUSTOM_PHP_VERSION}.so' > ${CUSTOM_PHP_INI_PATH})

# Add SendMail to Php.ini
RUN (echo 'sendmail_path=/usr/bin/msmtp -t' > ${CUSTOM_PHP_INI_PATH})

# Add Default Time to Php.ini
RUN (echo 'date.timezone=Asia/Kolkata' > ${CUSTOM_PHP_INI_PATH})

# Move php.ini to
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Test Php.ini
# RUN echo php -i | grep date.timezone
# RUN echo php -i | grep sendmail_path

# Install xdebug
RUN pecl install xdebug-3.4.1 && \
    docker-php-ext-enable xdebug && \
    mkdir /var/log/xdebug

# Send Mail - MSMTP
RUN apt-get update && apt-get install -y msmtp
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail
RUN touch /etc/msmtprc
RUN chmod 777 /etc/msmtprc

# set locale to utf-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Clear up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# User Permission/User Add
ARG USER=docker
RUN groupadd --gid 1000 $USER \
    && useradd --uid 1000 --gid $USER --shell /bin/bash --create-home $USER
RUN adduser $USER sudo

# Update Permission
RUN chown $USER:www-data /var/www/html;

# Use the Current User
USER $USER

# Update Composer Auth File
RUN mkdir -p /home/$USER/.composer && \
    touch /home/$USER/.composer/auth.json && \
    echo "{" > /home/$USER/.composer/auth.json && \
    echo "}" >> /home/$USER/.composer/auth.json && \
    mkdir -p /home/$USER/.magento-cloud/bin && \
    chown -R $USER:$USER /home/$USER

# Magento Cloud Installation
RUN curl -sS https://accounts.magento.cloud/cli/installer | php
RUN export PATH=$PATH:$HOME/.magento-cloud/bin

# Composer Bash Reload
RUN echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc

# Set working directory
WORKDIR /var/www/html
