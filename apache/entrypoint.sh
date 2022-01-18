#!/usr/bin/env bash
set -e

# If env variables SSL_KEY and SSL_CRT are set, configure apache for SSL access
if [ ! -z "$SSL_KEY" ] && [ ! -z "$SSL_CRT" ]; then
  echo -n "* Enabling SSL..."
  echo "$SSL_KEY" | sed 's/^ *//;s/ *$//' > /etc/ssl/certs/server.key
  echo "$SSL_CRT" | sed 's/^ *//;s/ *$//' > /etc/ssl/certs/server.crt
  servername=$(openssl x509 -in /etc/ssl/certs/server.crt  -noout -ext subjectAltName | grep DNS | cut -f 2 -d ":")
  echo " certificate for servername: $servername"
  ln -s /usr/local/apache2/conf/extra/httpd-vhost-ssl.conf.dummy /usr/local/apache2/conf/extra/httpd-vhost-ssl.conf
else
  rm /usr/local/apache2/conf/extra/httpd-vhost-ssl.conf
fi

export APP_WEBROOT=${APP_WEBROOT:-/app/html}
export PHP_HOSTNAME=${PHP_HOSTNAME:-php}
export PHP_PORT=${PHP_PORT:-9000}

echo "* DocumentRoot: $APP_WEBROOT"
echo "* PHP-FPM: $PHP_HOSTNAME:$PHP_PORT"

# Now start the original entrypoint of the httpd container
exec httpd-foreground
