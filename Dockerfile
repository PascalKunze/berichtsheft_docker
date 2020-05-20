FROM php:7.2-apache

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    sshpass \
    curl \
    git \
	openssh-client \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    zip \
    libgpgme-dev \
    vim \
    less \
  && rm -rf /var/lib/apt/lists/*



RUN docker-php-ext-install mysqli 

RUN docker-php-ext-install calendar pdo_mysql \
    && docker-php-ext-install pcntl zip \
    && docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
        docker-php-ext-install gd

RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
	php composer-setup.php && php -r "unlink('composer-setup.php');"  && \
	mv composer.phar /usr/local/bin/composer

ARG username=dev

ARG userid=1000

RUN groupadd -g $userid $username && \
    useradd -r -u $userid -g $username $username && \
    mkdir -p /home/$username && \
    chown $userid:$userid /home/$username

ADD 001-berichtsheft.conf /etc/apache2/sites-available/
RUN sed -i "s/80/9642/g" /etc/apache2/sites-available/001-berichtsheft.conf /etc/apache2/ports.conf && \
    chown $userid:$userid /var/lock/apache2 && \
    chown $userid:$userid /var/log/apache2 && \
    chown $userid:$userid /var/run/apache2/ && \
    ln -s /etc/apache2/sites-available/001-berichtsheft.conf /etc/apache2/sites-enabled/001-berichtsheft.conf

RUN a2enmod rewrite

USER $userid:$userid


RUN echo 'alias ll="ls -lah"' >> ~/.bashrc

