ARG VARIANT=7-apache-bullseye
FROM litespeedtech/openlitespeed:${VARIANT}


ENV PHP_INI_SCAN_DIR=:/usr/local/etc/php/conf-custom.d


# Copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/
COPY ./scripts/* /tmp/scripts/
COPY entry.sh /entry.sh

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=www
ARG PUID=1000
ARG PGID=$PUID

RUN apt-get update 
RUN  bash /tmp/library-scripts/common-ubuntu.sh "${INSTALL_ZSH}" "${USERNAME}" "${PUID}" "${PGID}" "${UPGRADE_PACKAGES}" "true" "true" 

RUN  apt-get -y install --no-install-recommends lynx 

RUN  usermod -aG www-data ${USERNAME} 

# 创建 php conf custom 文件夹
RUN  mkdir /usr/local/etc/php/conf-custom.d 

# 遍历文件夹，按照文件名排序，依次执行 script
RUN  for script in $(ls /tmp/scripts/*.sh | sort); do \
  echo "\n\n========================== Processing $script ==========================\n\n"; \
  chmod +x $script; \
  $script || exit 1; \
  done 

RUN  apt-get autoremove --purge -y 

RUN  apt-get autoclean -y 

RUN  apt-get clean -y 

RUN  rm -rf /var/lib/apt/lists/* 

RUN  rm -rf /tmp/* /var/tmp/* 

RUN  chmod +x /entry.sh

ENTRYPOINT [ "/entry.sh", "/entrypoint.sh" ]
