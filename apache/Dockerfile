# See https://hub.docker.com/_/httpd/
FROM httpd:2.4

# We will need openssl tool for the entrypoint
RUN apt-get -qq update && apt-get -q install -y openssl && rm -rf /var/lib/apt/lists/*

# Prepare our apache configuration
RUN rm /usr/local/apache2/conf/extra/httpd-vhosts.conf /usr/local/apache2/conf/original/extra/httpd-ssl.conf
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY httpd-vhost.conf /usr/local/apache2/conf/extra/httpd-vhost.conf
COPY httpd-vhost-ssl.conf /usr/local/apache2/conf/extra/httpd-vhost-ssl.conf.dummy
RUN chmod 644 /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/extra/httpd-*

# We need an alternative entrypoint to do some stuff upon starting the container
COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

# Also expose SSL port
EXPOSE 80 443

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
