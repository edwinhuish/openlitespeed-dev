#!/usr/bin/env bash

set -e

DEBIAN_FRONTEND=noninteractive apt-get update

DEBIAN_FRONTEND=noninteractive apt-get -y install \
  g++ \
  libbz2-dev \
  libc-client-dev \
  libcurl4-gnutls-dev \
  libedit-dev \
  libfreetype6-dev \
  libicu-dev \
  libkrb5-dev \
  libldap2-dev \
  libldb-dev \
  libmagickwand-dev \
  libmcrypt-dev \
  libpng-dev \
  libpq-dev \
  libsqlite3-dev \
  libssl-dev \
  libreadline-dev \
  libxslt1-dev \
  libzip-dev \
  wget \
  unzip \
  zlib1g-dev \
  vim \
  iputils-ping

echo "export PATH=/usr/local/lsws/$PHP_VERSION/bin:/usr/local/lsws/bin:\$PATH" > /etc/profile.d/00-lsws-env.sh
chmod +x /etc/profile.d/00-lsws-env.sh

# 默认增加 lsrestart.log， 避免权限问题
touch /usr/local/lsws/logs/lsrestart.log
chown nobody:nogroup /usr/local/lsws/logs/lsrestart.log

# 更改 lswsctrl
rm /usr/local/lsws/bin/lswsctrl
cat > /usr/local/lsws/bin/lswsctrl <<EOF
#!/bin/bash

BASE_DIR=\`dirname "\$0"\`

sudo "\$BASE_DIR/lswsctrl.open" \$@
EOF
chmod +x /usr/local/lsws/bin/lswsctrl

# 更改 lshttpd
rm /usr/local/lsws/bin/lshttpd
cat > /usr/local/lsws/bin/lshttpd <<EOF
#!/bin/bash

BASE_DIR=\`dirname "\$0"\`

sudo "\$BASE_DIR/openlitespeed" \$@
EOF
chmod +x /usr/local/lsws/bin/lshttpd
