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
        cronie-noanacron \
        git \
        gcc \
        libnsl \
        libaio \
        openssl-devel \
        procps-ng \
        python-devel \
        python-pip && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/1912000/oracle-instantclient19.12-basiclite-19.12.0.0.0-1.x86_64.rpm; \
    echo "/usr/lib/oracle/19/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig

RUN rpm -i https://github.com/dshearer/jobber/releases/download/v1.4.0/jobber-1.4.0-1.el7.x86_64.rpm

# Downgrade setuptools to avoid compatibility issues
# TODO: remove once https://github.com/rucio/containers/issues/458 is resolved
RUN dnf -y install https://vault.almalinux.org/9.6/BaseOS/x86_64/os/Packages/python3-setuptools-53.0.0-13.el9_6.1.noarch.rpm

RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir --upgrade setuptools
RUN rm -rf /usr/lib/python3.6/site-packages/ipaddress*
RUN python3 -m pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql]
RUN python3 -m pip install --no-cache-dir psycopg2-binary
RUN python3 -m pip install --no-cache-dir cx-oracle PyMySQL

WORKDIR /
RUN git clone https://github.com/rucio/probes.git

ADD rucio.config.default.cfg /tmp/

ADD run-probes.sh /
ADD DeterministicDelay /

ENTRYPOINT ["/run-probes.sh"]
