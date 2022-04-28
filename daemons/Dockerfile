# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Cedric Serfon, <cedric.serfon@cern.ch>, 2017
# - Thomas Beermann, <thomas.beermann@cern.ch>, 2018-2020

FROM centos:7

ARG TAG

WORKDIR /tmp

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum -y install https://repo.ius.io/ius-release-el7.rpm &&\
    yum install -y python36u-pip libaio gcc python36-devel.x86_64 openssl-devel.x86_64 mod_ssl python36-m2crypto libnsl.x86_64 memcached patch.x86_64 && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/1912000/oracle-instantclient19.12-basiclite-19.12.0.0.0-1.x86_64.rpm; \
    echo "/usr/lib/oracle/19/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig
RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir --upgrade setuptools
RUN rm -rf /usr/lib/python3.6/site-packages/ipaddress*
RUN python3 -m pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql,globus]==$TAG
RUN python3 -m pip install --no-cache-dir j2cli

# Install dependecies
RUN yum install -y \
    python3-gfal2 \
    gfal2-plugin-file \
    gfal2-plugin-gridftp \
    gfal2-plugin-http \
    gfal2-plugin-srm \
    gfal2-plugin-xrootd \
    xrootd-client \
    sendmail \
    sendmail-cf && \
    yum clean all && \
    rm -rf /var/cache/yum

ADD rucio.config.default.cfg /tmp/
ADD start-daemon.sh /

RUN mkdir /var/log/rucio

VOLUME /var/log/rucio
VOLUME /opt/rucio/etc

ENTRYPOINT ["/start-daemon.sh"]
