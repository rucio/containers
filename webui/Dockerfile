# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Mayank Sharma, <mayank.sharma@cern.ch>, 2022

FROM node:16-alpine as builder
ARG TAG
LABEL stage=builder
# Install git
RUN apk update && apk add --no-cache git python3
# Git Clone the source code for the webui
RUN git clone --depth 1 -b ${TAG} -- https://github.com/maany/webui.git
# Set the working directory
WORKDIR /webui
# Install dependencies (npm ci makes sure the exact versions in the lockfile gets installed)
RUN npm ci --legacy-peer-deps 
# Build the app
RUN npm run build


FROM quay.io/centos/centos:stream8 as production
LABEL stage=production
RUN dnf -y update && \
    dnf -y install httpd mod_ssl python39 git && \
    dnf clean all

RUN curl https://raw.githubusercontent.com/rucio/rucio/master/tools/merge_rucio_configs.py > /usr/bin/merge_rucio_configs.py
RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir j2cli

# Copy the build output to the web root
COPY --from=builder /webui/build /var/www/html

COPY robots.txt /var/www/html
COPY httpd.conf.j2 /tmp/
COPY rucio.conf.j2 /tmp
COPY docker-entrypoint.sh /

RUN rm /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/ssl.conf

VOLUME /var/log/httpd

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]