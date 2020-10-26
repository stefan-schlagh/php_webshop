FROM php:7.4.3-apache
RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils && apt-get install git -y && apt-get install libzip-dev -y
RUN docker-php-ext-install mysqli pdo pdo_mysql zip
COPY .env /var/www/.env