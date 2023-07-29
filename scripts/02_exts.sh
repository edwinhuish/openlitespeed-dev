#!/usr/bin/env bash

set -e

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ${PHP_VERSION}-pear
