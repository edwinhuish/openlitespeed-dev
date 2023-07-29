#!/usr/bin/env bash

set -e

XDEBUG_VERSION=3.2.2
if [[ $PHP_VERSION == lsphp7* ]]; then
  XDEBUG_VERSION=3.1.5
fi


mkdir /tmp/xdebug

cd /tmp/xdebug

wget http://xdebug.org/files/xdebug-${XDEBUG_VERSION}.tgz
tar -xvzf xdebug-${XDEBUG_VERSION}.tgz

cd xdebug-${XDEBUG_VERSION}

/usr/local/lsws/${PHP_VERSION}/bin/phpize

./configure --with-php-config="/usr/local/lsws/${PHP_VERSION}/bin/php-config"

make

EXT_DIR=`/usr/local/lsws/${PHP_VERSION}/bin/php -i | grep extension_dir | awk -F '=>' '{print $2}' | sed 's/ //g'`
cp modules/xdebug.so "${EXT_DIR}"

CONFIG_DIR=`/usr/local/lsws/${PHP_VERSION}/bin/php -i | grep "Scan this dir" | awk -F '=>' '{print $2}' | sed 's/ //g'`

XDEBUG_INI_FILE="${CONFIG_DIR}/xdebug.ini"

cat > $XDEBUG_INI_FILE <<EOF
zend_extension=xdebug.so
xdebug.mode=no
xdebug.start_with_request=yes
xdebug.client_host=localhost
xdebug.client_port=9003
EOF

# 将配置文件修改为任何人可读写
chmod a+rw $XDEBUG_INI_FILE

cat > /usr/local/bin/xdebug_mode <<EOF
#!/bin/bash

CONFIG_DIR=${CONFIG_DIR}
XDEBUG_MODE=\${1:-'develop,debug'}
XDEBUG_INI_FILE=\${CONFIG_DIR}/xdebug.ini

if grep -q '^xdebug.mode' "\$XDEBUG_INI_FILE" ; then 
  cp "\$XDEBUG_INI_FILE" /tmp/xdebug_tmp.ini
  sed -i "s/^xdebug\.mode.*/xdebug\.mode=\${XDEBUG_MODE}/" /tmp/xdebug_tmp.ini
  cat /tmp/xdebug_tmp.ini > "\$XDEBUG_INI_FILE"
  rm /tmp/xdebug_tmp.ini
else 
  echo "xdebug.mode=\${XDEBUG_MODE}" >> "\$XDEBUG_INI_FILE"
fi
EOF

chmod +x /usr/local/bin/xdebug_mode
