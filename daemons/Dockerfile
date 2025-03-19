# Copyright European Organization for Nuclear Research (CERN) 2023
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

FROM almalinux:9

ARG TAG

WORKDIR /tmp

RUN dnf install -y epel-release.noarch && \
    dnf upgrade -y && \
    dnf install -y \
        fetch-crl \
        gfal2-plugin-file \
        gfal2-plugin-gridftp \
        gfal2-plugin-http \
        gfal2-plugin-srm \
        gfal2-plugin-xrootd \
        libnsl \
        libaio \
        patch \
        python-gfal2 \
        procps-ng \
        python-pip \
        python-mod_wsgi \
        sendmail \
        sendmail-cf \
        memcached \
        patchutils \
        xrootd-client && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# cx_oracle requires `gcc` and Python headers, not present by default on arm64
ARG TARGETARCH
RUN if [ $TARGETARCH = "arm64" ]; then \
        dnf install -y \
            gcc \
            python3-devel \
    ; fi

RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/1912000/oracle-instantclient19.12-basiclite-19.12.0.0.0-1.x86_64.rpm; \
    echo "/usr/lib/oracle/19/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig

RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir --upgrade setuptools
RUN python3 -m pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql,globus]==$TAG

RUN python3 -m pip install --no-cache-dir j2cli
ADD rucio.config.default.cfg /tmp/
ADD start-daemon.sh /

RUN update-crypto-policies --set DEFAULT:SHA1

RUN mkdir /var/log/rucio

VOLUME /var/log/rucio
VOLUME /opt/rucio/etc

ARG POLICY_PACKAGE_REQUIREMENTS
ARG USER=root
USER root
RUN if [ -n "$POLICY_PACKAGE_REQUIREMENTS" ]; then \
        dnf install -y git && \
        for package in $(echo $POLICY_PACKAGE_REQUIREMENTS | tr "," "\n"); do \
            python3 -m pip install --no-cache-dir $package; \
        done; \
        dnf remove -y git && \
        dnf autoremove && \
        dnf clean all; \
    fi
USER ${USER}

ENTRYPOINT ["/start-daemon.sh"]
