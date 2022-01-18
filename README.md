# cron PHP application docker images

## Abstract

Opinionated docker images for running PHP-Applications used at cron IT GmbH - mostly
for TYPO3 projects.

Images for **amd64** and **arm64** (i.e. also run on Apple M1).

This was born out of the desire to build good (and simple) multi platform images for our
developers to be able to work  also on M1 / ARM machines on the TYPO3 projects.

Main goals:
- As near as possible to the official images
- Configuration through environment variables
- Using best practices which proved good with our PHP projects in the last years

## Docker Images included

Included are four different images which can be combined together in a projects for a basic
PHP web development. Currently:

* `croneu/phpapp-ssh:php-7.4`
* `croneu/phpapp-phpfpm:php-7.4`
* `croneu/phpapp-webserver:httpd-2.4`
* `croneu/phpapp-db:mariadb-10.7`

### PHP application

Application root is `/app`. Application runs as user `application` (uid=1000).

#### PHP-FPM (image `croneu/phpapp-phpfpm`)

PHP runs as PHP-FPM (image `croneu/phpapp-phpfpm`), based on the offical images and
including the following additional extensions:

* apcu
* bcmath
* bz2
* calendar
* exif
* gd
* gettext
* igbinary
* imagick
* intl
* mcrypt
* mysqli
* opcache
* pcntl
* pdo_mysql
* redis
* shmop
* sockets
* sysvmsg
* sysvsem
* sysvshm
* uuid
* xdebug
* yaml
* zip

Additionally, it includes the following utilities for TYPO3 specific workflows:

* GraphicsMagick
* curl
* exiftool
* poppler-utils (for pdftotext etc)

#### SSH image (image `croneu/phpapp-ssh`)

You can start a container for SSH'ing into it for development purposes with the image
`croneu/phpapp-ssh`. It is based off the `phpapp-phpfpm` image (thus it contains the exact same
version and extensions installed) but additionally includes a set of tools to work with
the application from the command line:

* Composer v2
* NodeJS (currently only v14)
* Convenience tools: git, zip, make, ping, less, vi, wget, joe, jq, rsync, patch
* clitools from WebdevOps
* MySQL client
* GraphicsMagick
* exiftool, poppler-utils

### Webserver (image `croneu/phpapp-webserver`)

Currently, only Apache 2.4, so that the `.htaccess` files work out of the box. This
is based on the official image with pre-configured VirtualHost's to work with the
PHP-FPM image.

It also includes full HTTP/2 support and HTTPS flavours.

To activate **HTTPS**, simply generate your certificates with `mkcert` and include these
in your `.env` - the image will automatically use these and generate a valid HTTPS
Vhost.  See variables `SSL_CRT` and `SSL_KEY` in the example `.env.example`.

### MySQL Database (image `croneu/phpapp-db`)

This is just a pre-configured alternative to the upstream official **MariaDB** image. This
allows us to use it straight on for TYPO3 projects without having to include any further
configuration or do any performance tuning.

## Usage in a nutshell

Copy the files from `example-app/` folder to your new application, tweak, and you are
ready to go.

### Web Server

The `web` container will start a web-server listening on the port you specified in
`docker-compose.yml` (default is 8000 and 8443).

To access the web-server, make sure you have a DNS entry in your local `/etc/hosts`
or local DNS server:

`/etc/hosts` for `docker-machine`:
```
192.168.99.100 my-app.vm
```

`/etc/hosts` for Docker for Mac or locally on Linux:
```
127.0.0.1 my-app.vm
```

Then you can access the web-server:

* http://my-app.vm:8080/
* https://my-app.vm:8443/

### SSH Access

You can then SSH into the container using for example:

```bash
ssh -A -p 1122 application@my-app.vm
```

----

## Docker Image Development

```
make build
```

This will create all images from scratch

### Create a build for a specific PHP Version

Use the available targets in the `Makefile`, e.g.

```
make build-7.3
```

Important note: There is no automation on Docker Hub to build Docker Images other than `latest`.
Use the `push-*` targets in the Makefile to push the images to Docker Hub.

```
docker login
make push-7.3
```

### Test the Docker Image

To test the image you can use the supplied docker-compose files in the `example` directory. For example, to run a behat enabled environment using the official Neos Distribution Package, do:

```shell
cd example
docker-compose -f docker-compose.yml -f docker-compose.behat.yml up -d
# ssh-keygen -R \[$(docker-machine ip $DOCKER_MACHINE_NAME)\]:1122
ssh www-data@$(docker-machine ip $DOCKER_MACHINE_NAME) -p 1122
```

Inside the docker container, run this simple behat test:

```
cd Packages/Neos/Neos.Neos/Tests/Behavior
behat Features/ExportImport.feature
```

## MIT Licence

See the [LICENSE](LICENSE) file.

## Author

Ernesto Baschny (eb@cron at eu)
