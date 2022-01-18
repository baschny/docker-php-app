# See https://hub.docker.com/_/mariadb/

ARG MARIADB_VERSION=10.7

FROM mariadb:${MARIADB_VERSION}

ADD mariadb-docker.cnf /etc/mysql/conf.d/z99-docker.cnf
RUN chown mysql:mysql /etc/mysql/conf.d/z99-docker.cnf \
    && chmod 0644 /etc/mysql/conf.d/z99-docker.cnf
