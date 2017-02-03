#!/bin/sh
rm /usr/local/apache2/conf/httpd.conf

ln -s /usr/local/apache2/local/conf/httpd.conf /usr/local/apache2/conf/httpd.conf

ln -s /usr/local/apache2/local/conf/httpd-cosign.conf /usr/local/apache2/conf/extra/httpd-cosign.conf

/usr/local/apache2/bin/httpd -DFOREGROUND