# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Mayank Sharma, <mayank.sharma@cern.ch>, 2022
# - Eraldo Junior <ejunior@cbpf.br>, 2023

FROM almalinux:9

ARG TAG

LABEL stage=production
RUN dnf -y update && \
    dnf -y module reset nodejs && \
    dnf -y module enable nodejs:20 && \
    dnf -y module install nodejs:20/common && \
    dnf -y install httpd mod_ssl python39 python-pip git procps patch patchutils && \
    dnf -y install wget && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir --upgrade setuptools
RUN python3 -m pip install --no-cache-dir j2cli

WORKDIR /opt/rucio/webui

ENV RUCIO_WEBUI_PATH=/opt/rucio/webui

RUN curl https://raw.githubusercontent.com/rucio/rucio/master/tools/merge_rucio_configs.py --output /opt/rucio/merge_rucio_configs.py
RUN git clone --depth 1 -b ${TAG} -- https://github.com/rucio/webui.git ${RUCIO_WEBUI_PATH}

RUN npm i -g pm2
RUN npm install

COPY docker-entrypoint.sh /
COPY httpd.conf.j2 /tmp/
COPY rucio.conf.j2 /tmp/
COPY ecosystem.config.js /opt/rucio/webui/ecosystem.config.js

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]