#FROM php:7.4.3-apache

#install git & libzip
#RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils && apt-get install git -y && apt-get install libzip-dev -y

#RUN docker-php-ext-install mysqli pdo pdo_mysql zip

# Install Composer
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
#php -r "if (hash_file('sha384', 'composer-setup.php') === '795f976fe0ebd8b75f26a6dd68f78fd3453ce79f32ecb33e7fd087d39bfeb978342fb73ac986cd4f54edd0dc902601dc') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
#php composer-setup.php &&\
#php -r "unlink('composer-setup.php');"

# Install Composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#COPY initPhp.sh /var/
#RUN composer install

#FROM composer as composer
#COPY ./html /app
#RUN composer install --ignore-platform-reqs --no-scripts

FROM php:7.4.3-apache
#WORKDIR /var/www/html/
RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils && apt-get install git -y && apt-get install libzip-dev -y
RUN docker-php-ext-install mysqli pdo pdo_mysql zip
#RUN apt-get update && apt-get upgrade -y && apt-get install -y \
 #       apt-utils \
  #      lipzip \
   #     git \
    #    zip \
     #   unzip \
    #&& docker-php-ext-install mysqli pdo pdo_mysql zip
#COPY ./html /var/www/html
#COPY --from=composer /app/vendor /var/composer/vendor