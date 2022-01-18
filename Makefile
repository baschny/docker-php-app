#
# Image naming / tagging:
# Schema: croneu/phpapp-<service>:<base-package>-<base-version>
#
# - croneu/phpapp-ssh:php-7.4-node-14
# - croneu/phpapp-phpfpm:php-7.4
# - croneu/phpapp-webserver:httpd-2.4
# - croneu/phpapp-db:mariadb-10.7

PLATFORMS=linux/arm64/v8,linux/amd64

# Defaults:
HTTPD_VERSION=2.4
MARIADB_VERSION=10.7
PHP_VERSION=7.4
NODE_VERSION=14

#BUILDX_OPTIONS=--push
DOCKER_CACHE=--cache-from "type=local,src=.buildx-cache" --cache-to "type=local,dest=.buildx-cache"

build-webserver:
	docker buildx build $(DOCKER_CACHE) $(BUILDX_OPTIONS) \
		--platform $(PLATFORMS) \
		--tag croneu/phpapp-webserver:httpd-$(HTTPD_VERSION) apache

build-db:
	docker buildx build $(DOCKER_CACHE) $(BUILDX_OPTIONS) \
		--platform $(PLATFORMS) \
		--build-arg MARIADB_VERSION=$(MARIADB_VERSION) --tag croneu/phpapp-db:mariadb-$(MARIADB_VERSION) mariadb

build-php:
	ssh-add -l
	env | sort
	docker buildx build $(DOCKER_CACHE) $(BUILDX_OPTIONS) \
		--platform $(PLATFORMS) \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		--tag croneu/phpapp-phpfpm:php-$(PHP_VERSION) \
		--target php-fpm php
	docker buildx build $(DOCKER_CACHE) $(BUILDX_OPTIONS) \
		--platform $(PLATFORMS) \
		--build-arg PHP_VERSION=$(PHP_VERSION) --build-arg NODE_VERSION=$(NODE_VERSION) \
		--tag croneu/phpapp-ssh:php-$(PHP_VERSION)-node-$(NODE_VERSION) \
		--target ssh php

build: build-php build-db build-webserver
