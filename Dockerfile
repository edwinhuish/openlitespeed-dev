ARG OLS_VERSION=1.7.17
ARG PHP_VERSION=lsphp80

FROM litespeedtech/openlitespeed:${OLS_VERSION}-${PHP_VERSION}

ARG OLS_VERSION=1.7.17
ARG PHP_VERSION=lsphp80

ENV OLS_VERSION=${OLS_VERSION}
ENV PHP_VERSION=${PHP_VERSION}
ENV PHP_CONF_PATH=/usr/local/lsws/lsphp80/etc/php/8.0

# RUN ln -sf /usr/local/lsws/$PHP_VERSION/bin/php /usr/local/sbin/php
RUN PHP_CONF_PATH=`/usr/local/lsws/${PHP_VERSION}/bin/php -i | grep "Loaded Configuration File" | awk -F '=>' '{print $2}' | sed 's/ //g' | awk -F '/litespeed/php.ini' '{print $1}'` && \
  echo "PHP_CONF_PATH=${PHP_CONF_PATH}" && \
  mkdir /php && \
  mv "${PHP_CONF_PATH}/litespeed/php.ini" /php/php.ini && ln -s /php/php.ini "${PHP_CONF_PATH}/litespeed/php.ini" && \
  mv "${PHP_CONF_PATH}/mods-available" /php/conf.d && ln -s /php/conf.d "${PHP_CONF_PATH}/mods-available"

# Copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=www
ARG PUID=1000
ARG PGID=$PUID

ENV USERNAME=${USERNAME}
ENV GROUPNAME=${USERNAME}
ENV PUID=${PUID}
ENV PGID=${PGID}

RUN apt-get update && \
  bash /tmp/library-scripts/common-ubuntu.sh "${INSTALL_ZSH}" "${USERNAME}" "${PUID}" "${PGID}" "${UPGRADE_PACKAGES}" "true" "true"

# 遍历文件夹，按照文件名排序，依次执行 script
COPY ./scripts/* /tmp/scripts/
RUN for script in $(ls /tmp/scripts/*.sh | sort); do \
  echo "\n\n========================== Processing $script ==========================\n\n"; \
  chmod +x $script; \
  $script || exit 1; \
  done

# 清理文件
RUN apt-get autoremove --purge -y && \
  apt-get autoclean -y && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* /var/tmp/* 

# 增加入口文件
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

ENTRYPOINT [ "/entry.sh", "/entrypoint.sh" ]
