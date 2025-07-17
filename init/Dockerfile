# Copyright European Organization for Nuclear Research (CERN) 2025
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
        openssl-devel \
        mod_ssl \
        procps-ng \
        python3-devel \
        python3-m2crypto \
        python3-pip && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir --upgrade setuptools
RUN python3 -m pip install --pre rucio[oracle,mysql,postgresql]==$TAG
RUN python3 -m pip install jinja2 j2cli pyyaml

RUN mkdir -p /opt/rucio/etc

COPY rucio.config.default.cfg /tmp
COPY alembic.ini.j2 /tmp
COPY bootstrap.py /tmp
COPY docker-entrypoint.sh /

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

CMD ["/docker-entrypoint.sh"]
