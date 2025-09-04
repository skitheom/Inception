FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY conf/99-custom.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf
COPY tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
CMD ["mariadbd"]