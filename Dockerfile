FROM php:7.2

#Workspace
WORKDIR /var/www/blog/

ARG user=blog
ARG uid=1000

#Install system dependencies
#RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -y && apt-get upgrade -y;
    
RUN apt-get install -y \
    libzip-dev\
    zip \
    curl \
    libpng-dev

#Install node version 14.0
#RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
#RUN apt-get install -y nodejs

#Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#Install php extensions
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip
#RUN docker-php-ext-install zip

#Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

#Copy files of the dependences to workspace in container
COPY composer.json /var/www/blog/
COPY composer.lock /var/www/blog/

#Copy the file of the supervisor to folder
#COPY laravel-worker.conf /etc/supervisor/conf.d/

#Copy all files to workspace in container
COPY . . /var/www/blog/

#Run composer command to install dependencies
RUN composer update && composer install
#RUN composer require pusher/pusher-php-server "~3.0"
#RUN composer require predis/predis

#RUN npm install && npm run dev

#Expose the port to listen http petitions
EXPOSE 8080

ENTRYPOINT ["/bin/sh"]

#Run command to execute the app with the port 8080
CMD ["start-app.sh"]