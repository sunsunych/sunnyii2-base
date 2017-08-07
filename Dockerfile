FROM alpine:latest

RUN apk --update add bash wget dpkg-dev shadow

RUN apk add --update curl wget nginx postgresql openssh git \
    && \
    apk add --update  php7 php7-cli php7-common php7-fpm php7-opcache memcached-dev readline php7-session php7-tokenizer php7-simplexml php7-xmlwriter php7-dom php7-xml php7-xmlreader php7-ctype php7-ftp php7-gd php7-json php7-posix php7-curl php7-pdo php7-pdo_mysql php7-sockets php7-zlib php7-mcrypt php7-mysqli php7-sqlite3 php7-bz2 php7-phar php7-openssl php7-zip php7-calendar php7-iconv php7-imap php7-soap php7-dev php7-pear php7-redis php7-mbstring php7-xdebug php7-exif php7-xsl php7-bcmath php7-memcached php7-mysqlnd

RUN ln -sf /usr/bin/php7 /usr/bin/php && \
    ln -sf /usr/sbin/php-fpm7 /usr/bin/php-fpm

# Install composer 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD conf/nginx.conf /etc/nginx/
ADD conf/yii2.conf /etc/nginx/sites-available/
RUN mkdir /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/sites-available/yii2.conf /etc/nginx/sites-enabled/yii2.conf
COPY conf/php-fpm.conf /etc/php7/php-fpm.conf

# Install node
RUN apk add --update nodejs-npm

RUN mkdir /var/log/php && \
    touch /var/log/php/error.log && \
    touch /var/log/php/access.log && \
    touch /var/log/php/fpm-error.log && \
    touch /var/log/php/fpm-slow.log && \
    chown -R nginx:nginx /var/log/php

RUN useradd -g www-data www-data

RUN rm -rf /var/cache/apk/*

RUN mkdir /app && mkdir /app/web
RUN touch /app/web/index.php
# RUN echo "<?php phpinfo() ?>" >> /app/web/index.php
# RUN echo "done" >> /app/web/index.html

WORKDIR /app

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

RUN php-fpm -y /etc/php7/php-fpm.conf 



CMD service nginx start

RUN php-fpm

CMD ["nginx"]