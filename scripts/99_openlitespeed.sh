#!/usr/bin/env bash

set -e

# user
sed -i "s/nobody/www/g" /usr/local/lsws/.conf/httpd_config.conf
sed -i "s/nobody/www/g" /usr/local/lsws/.conf/httpd_config.xml
# group
sed -i "s/nogroup/www/g" /usr/local/lsws/.conf/httpd_config.conf
sed -i "s/nogroup/www/g" /usr/local/lsws/.conf/httpd_config.xml

if [ -z "$(ls -A -- "/usr/local/lsws/conf/")" ]; then
	cp -R /usr/local/lsws/.conf/* /usr/local/lsws/conf/
fi

# user
sed -i "s/nobody/www/g" /usr/local/lsws/conf/httpd_config.conf
sed -i "s/nobody/www/g" /usr/local/lsws/conf/httpd_config.xml
# group
sed -i "s/nogroup/www/g" /usr/local/lsws/conf/httpd_config.conf
sed -i "s/nogroup/www/g" /usr/local/lsws/conf/httpd_config.xml
