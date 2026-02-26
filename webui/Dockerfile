# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Mayank Sharma, <mayank.sharma@cern.ch>, 2022
# - Eraldo Junior <ejunior@cbpf.br>, 2023

# ---------- Stage 1: builder (clone repo & install node deps) ----------
FROM almalinux:10 AS builder

ARG TAG

ENV NODE_ENV=production

RUN dnf -y update && \
    dnf -y install git nodejs24 nodejs24-npm && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    ln -s /usr/bin/node-24 /usr/local/bin/node && \
    ln -s /usr/bin/npm-24 /usr/local/bin/npm && \
    ln -s /usr/bin/npx-24 /usr/local/bin/npx

WORKDIR /opt/rucio/webui

ENV RUCIO_WEBUI_PATH=/opt/rucio/webui

RUN curl https://raw.githubusercontent.com/rucio/rucio/master/tools/merge_rucio_configs.py --output /opt/rucio/merge_rucio_configs.py
RUN git clone --depth 1 -b ${TAG} -- https://github.com/rucio/webui.git ${RUCIO_WEBUI_PATH}

RUN npm i -g pm2
RUN npm install --omit=dev

# Pre-build env-generator so it's ready at runtime (needs dev deps for tsc)
WORKDIR /opt/rucio/webui/tools/env-generator
RUN npm install --include=dev && npx tsc --skipLibCheck && cp -rf src/templates dist/
WORKDIR /opt/rucio/webui

# ---------- Stage 2: runtime ----------
FROM almalinux:10

LABEL stage=production
ENV NODE_ENV=production

RUN dnf -y update && \
    dnf -y install nodejs24 nodejs24-npm httpd mod_ssl python3 python3-jinja2 procps patch patchutils && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    ln -s /usr/bin/node-24 /usr/local/bin/node && \
    ln -s /usr/bin/npm-24 /usr/local/bin/npm && \
    ln -s /usr/bin/npx-24 /usr/local/bin/npx

COPY j2.py /usr/local/bin/
RUN ln -s j2.py /usr/local/bin/j2

RUN npm i -g pm2

WORKDIR /opt/rucio/webui

ENV RUCIO_WEBUI_PATH=/opt/rucio/webui

COPY --from=builder /opt/rucio/webui/ /opt/rucio/webui/
COPY --from=builder /opt/rucio/merge_rucio_configs.py /opt/rucio/merge_rucio_configs.py

COPY docker-entrypoint.sh /
COPY httpd.conf.j2 /tmp/
COPY rucio.conf.j2 /tmp/
COPY ecosystem.config.js /opt/rucio/webui/ecosystem.config.js

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
