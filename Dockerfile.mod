#FROM debian:jessie
FROM ubuntu:14.04

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
#RUN groupadd -r www-data && useradd -r --create-home -g www-data www-data

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin
RUN mkdir -p "$HTTPD_PREFIX" \
	&& chown www-data:www-data "$HTTPD_PREFIX"
WORKDIR $HTTPD_PREFIX

# install httpd runtime dependencies
# https://httpd.apache.org/docs/2.4/install.html#requirements
# ckretler: had to add ldap lib for switching to ubuntu 14.04.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libapr1 \
		libaprutil1 \
		libapr1-dev \
		libaprutil1-dev \
		libpcre++0 \
		libssl1.0.0 \
		libldap-2.4-2 \
		git \
		autoconf \
	&& rm -r /var/lib/apt/lists/*

# see https://httpd.apache.org/download.cgi#verify
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys A93D62ECC3C8EA12DB220EC934EA76E6791485A8

ENV HTTPD_VERSION 2.4.25
ENV HTTPD_BZ2_URL https://www.apache.org/dist/httpd/httpd-$HTTPD_VERSION.tar.bz2

###### BUILD APACHE #####
# install build dependencies, build, then purge the dependencies
RUN buildDeps=' \
		ca-certificates \
		curl \
		bzip2 \
		gcc \
		libpcre++-dev \
		libssl-dev \
		make \
		wget \
	' \
	set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& rm -r /var/lib/apt/lists/* \
	&& curl -SL "$HTTPD_BZ2_URL" -o httpd.tar.bz2 \
	&& curl -SL "$HTTPD_BZ2_URL.asc" -o httpd.tar.bz2.asc \
	&& gpg --verify httpd.tar.bz2.asc \
	&& mkdir -p src/httpd \
	&& tar -xvf httpd.tar.bz2 -C src/httpd --strip-components=1 \
	&& rm httpd.tar.bz2* \
	&& cd src/httpd \
	&& ./configure --enable-so --enable-ssl --prefix=$HTTPD_PREFIX --enable-mods-shared=most \
	&& make -j"$(nproc)" \
	&& make install


###### BUILD COSIGN #####
WORKDIR $HTTPD_PREFIX
#ENV COSIGN_VERSION 3.2.0
#ENV COSIGN_URL #http://downloads.sourceforge.net/project/cosign/cosign/cosign-3.2.0/cosign-3.2.0.tar.gz
ENV CPPFLAGS="-I/usr/kerberos/include"

#RUN wget "$COSIGN_URL" \
RUN cd ./src \
	&& git clone -b cosign-3.2.1rc1 http://github.com/umich-iam/cosign
	
WORKDIR /usr/local/apache2/src/cosign
#	&& cd ./cosign
#	&& tar -xvf cosign-3.2.0.tar.gz -C src/cosign --strip-components=1 \
#	&& rm cosign-3.2.0.tar.gz \
#	&& cd src/cosign \

RUN apt-get install -y libtool-bin automake

RUN libtoolize --force
RUN aclocal
#RUN ls
RUN autoheader #configure.ac
RUN automake --force-missing --add-missing
RUN autoconf

#RUN ./cosign/libcgi/configure --enable-apache2=/usr/local/apache2/bin/apxs \
#	&& sed -i 's/remote_ip/client_ip/g' ./filters/apache2/mod_cosign.c \
#	&& make \
#	&& make install \
#	&& cd ../../ \
#	&& rm -r src/cosign

CMD /bin/bash

