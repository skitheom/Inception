FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        php-fpm \
        php-mysqli \
        php-xml \
        php-mbstring \
        php-curl \
        php-zip \
        curl \
        mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# WordPress 用 PHP-FPM 設定
RUN mkdir -p /run/php
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/

# wp-cli をインストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# WordPress の作業ディレクトリ
WORKDIR /var/www/html/

# Entrypoint スクリプト
COPY tools/wordpress-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm7.4", "-F"]