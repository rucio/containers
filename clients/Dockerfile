# Copyright European Organization for Nuclear Research (CERN) 2025
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

FROM almalinux:9

ARG TAG

RUN dnf -y install yum-utils epel-release.noarch && \
    dnf upgrade -y && \
    yum-config-manager --enable crb && \
    dnf install -y \
        gfal2-all \
        python3-gfal2-util \
        python3-gfal2 \
        python3-pip \
        nordugrid-arc-client \
        nordugrid-arc-plugins-gfal \
        nordugrid-arc-plugins-globus \
        nordugrid-arc-plugins-s3 \
        nordugrid-arc-plugins-xrootd \
        voms-clients-java \
        xrootd-client && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Upgrade pip & setuptools and install Rucio
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir --upgrade setuptools && \
    python3 -m pip install --no-cache-dir --pre rucio-clients[argcomplete]==$TAG && \
    python3 -m pip install --no-cache-dir jinja2 j2cli pyyaml


# Add a separate user and change ownership of config dir to that user
RUN groupadd -g 1000 user && \
    useradd -ms /bin/bash -u 1000 -g 1000 user && \
    mkdir -p /opt/rucio/etc/ && \
    chown -R user:user /opt/rucio/etc/ && \
    mkdir -p /opt/user && \
    chown user:user /opt/user

USER user
WORKDIR /home/user

# Add the default rucio configuration
ADD --chown=user:user rucio.default.cfg /opt/user/rucio.default.cfg
ADD init_rucio.sh /etc/profile.d/rucio_init.sh
ADD --chown=user:user ./entrypoint.sh /opt/user/entrypoint.sh

ENV PATH $PATH:/opt/rucio/bin

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

ENTRYPOINT ["/opt/user/entrypoint.sh"]
CMD ["bash"]
