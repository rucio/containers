# Copyright European Organization for Nuclear Research (CERN) 2020
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Eric Vaandering, <ewv@fnal.gov>, 2020

FROM almalinux:9

WORKDIR /tmp
ADD oic.rpm /tmp

RUN dnf install -y epel-release.noarch && \
    dnf upgrade -y && \
    dnf install -y \
        git \
        gcc \
        openssl-devel \
        procps-ng \
        python-devel \
        python-pip && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN rpm -i https://github.com/dshearer/jobber/releases/download/v1.4.0/jobber-1.4.0-1.el7.x86_64.rpm

RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir --upgrade setuptools
RUN rm -rf /usr/lib/python3.6/site-packages/ipaddress*
RUN python3 -m pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql]
RUN python3 -m pip install --no-cache-dir j2cli psycopg2-binary
RUN python3 -m pip install --no-cache-dir cx-oracle PyMySQL

WORKDIR /
RUN git clone https://github.com/rucio/probes.git

ADD rucio.config.default.cfg /tmp/

ADD run-probes.sh /

ENTRYPOINT ["/run-probes.sh"]
