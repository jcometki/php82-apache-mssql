FROM php:8.2-apache

ENV TZ=America/Campo_Grande
ENV ACCEPT_EULA=Y

RUN echo 'date.timezone = America/Campo_Grande' > /usr/local/etc/php/conf.d/tzone.ini && \
    echo 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_WARNING' > /usr/local/etc/php/conf.d/php-errors.ini && \
    sed -i 's/%h/%h %{X-Forwarded-For}i/g' /etc/apache2/apache2.conf

RUN apt-get update && \
    apt-get install -y zip unzip curl nano gnupg2 apt-transport-https libpng-dev zlib1g-dev libmagickwand-dev libonig-dev libzip-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && \
    apt-get install -y msodbcsql18 odbcinst unixodbc-dev unixodbc && \
    rm -rf /var/lib/apt/lists/*

RUN pecl install sqlsrv pdo_sqlsrv imagick
RUN docker-php-ext-enable pdo_sqlsrv sqlsrv imagick
RUN docker-php-ext-configure gd
RUN docker-php-ext-install pdo_mysql mysqli gd mbstring zip calendar exif gettext

WORKDIR /var/www/html
RUN chown www-data:www-data /var/www/html
USER www-data

EXPOSE 80