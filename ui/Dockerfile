# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Thomas Beermann, <thomas.beermann@cern.ch>, 2019

FROM almalinux:9

ARG TAG

WORKDIR /tmp

RUN dnf install -y epel-release.noarch && \
    dnf upgrade -y && \
    dnf install -y \
        gcc \
        httpd \
        libnsl \
        libaio \
        openssl-devel \
        mod_ssl \
        procps-ng \
        python3-mod_wsgi \
        python3-m2crypto \
        python-devel \
        patch \
        patchutils \
        python-pip && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/1912000/oracle-instantclient19.12-basiclite-19.12.0.0.0-1.x86_64.rpm; \
    echo "/usr/lib/oracle/19/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig

# Downgrade setuptools to avoid compatibility issues
# TODO: remove once https://github.com/rucio/containers/issues/458 is resolved
RUN dnf -y install https://vault.almalinux.org/9.6/BaseOS/x86_64/os/Packages/python3-setuptools-53.0.0-13.el9_6.1.noarch.rpm

RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir --upgrade setuptools
RUN python3 -m pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql]==$TAG
RUN python3 -m pip install --no-cache-dir --pre rucio_webui==$TAG

COPY j2.py /usr/local/bin/
RUN python3 -m pip install --no-cache-dir jinja2 && \
    ln -s j2.py /usr/local/bin/j2

ADD rucio.config.default.cfg /tmp/
ADD rucio.conf.j2 /tmp/
ADD httpd.conf.j2 /tmp/
ADD 00-mpm.conf.j2 /tmp
ADD docker-entrypoint.sh /
RUN rm /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/ssl.conf

RUN update-crypto-policies --set DEFAULT:SHA1

VOLUME /var/log/httpd
VOLUME /opt/rucio/etc

EXPOSE 80
EXPOSE 443

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
        dnf clean all && \
        rm -rf /var/cache/dnf; \
    fi
USER ${USER}

ENTRYPOINT ["/docker-entrypoint.sh"]
