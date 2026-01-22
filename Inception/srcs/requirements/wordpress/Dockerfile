FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp


COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup-wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["setup-wordpress.sh"]