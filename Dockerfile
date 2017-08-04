FROM php:7.1-apache
MAINTAINER Gabriel Wicke <gwicke@wikimedia.org>

# System Dependencies.
RUN apt-get update && apt-get install -y \
		imagemagick \
		libicu-dev \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-install mbstring mysqli opcache intl

# Install the default object cache.
RUN pecl channel-update pecl.php.net \
  && pecl install apcu \
	&& docker-php-ext-enable apcu

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Version
ENV MEDIAWIKI_VERSION 1.29.0
ENV MEDIAWIKIL_MD5 2d038488d9219c97a21a1fe6a9d99020

# MediaWiki setup
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/1.29/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
	&& echo "${MEDIAWIKIL_MD5} *mediawiki.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f mediawiki.tar.gz \
	&& rm mediawiki.tar.gz \
	&& chown -R www-data:www-data extensions skins
