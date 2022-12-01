# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Mayank Sharma, <mayank.sharma@cern.ch>, 2022

FROM quay.io/centos/centos:stream8 as production
ARG TAG
LABEL stage=production
RUN dnf -y update && \
    dnf -y module reset nodejs && \
    dnf -y module enable nodejs:16 && \
    dnf -y module install nodejs:16/common && \
    dnf -y install httpd mod_ssl python39 git procps && \
    dnf clean all

RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir j2cli

WORKDIR /opt/rucio/webui
RUN curl https://raw.githubusercontent.com/rucio/rucio/master/tools/merge_rucio_configs.py --output /opt/rucio/merge_rucio_configs.py
RUN git clone --depth 1 -b ${TAG} -- https://github.com/rucio/webui.git /opt/rucio/webui
RUN npm ci --legacy-peer-deps 

COPY robots.txt /var/www/html
COPY httpd.conf.j2 /tmp/
COPY rucio.conf.j2 /tmp
COPY docker-entrypoint.sh /
COPY .env.default.j2 /tmp/

RUN rm /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/ssl.conf

VOLUME /var/log/httpd

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]