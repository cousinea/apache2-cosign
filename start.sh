#!/bin/sh

ln -s /usr/share/properties/httpd.conf /usr/local/apache2/conf/httpd.conf

ln -s /usr/share/properties/cosign.conf /usr/local/apache2/conf/cosign.conf

ln -s /usr/share/properties/workers.properties /usr/local/apache2/conf/workers.properties

/usr/local/apache2/bin/httpd -DFOREGROUND