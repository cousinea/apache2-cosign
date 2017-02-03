#!/bin/sh
rm /usr/local/apache2/conf/httpd.conf

ln -s /usr/local/apache2/local/conf/httpd.conf /usr/local/apache2/conf/httpd.conf

ln -s /usr/local/apache2/local/conf/httpd-cosign.conf /usr/local/apache2/conf/extra/httpd-cosign.conf

ln -sf /dev/stdout /usr/local/apache2/logs/access_log
ln -sf /dev/stderr /usr/local/apache2/logs/error_log

/usr/local/apache2/bin/httpd -DFOREGROUND 