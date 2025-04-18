FROM almalinux:9

ARG TAG

WORKDIR /tmp

RUN dnf install -y epel-release.noarch && \
    dnf upgrade -y && \
    dnf install -y \
        gcc \
        libnsl \
        libaio \
        openssl-devel \
        mod_ssl \
        procps-ng \
        python-devel \
        python3-m2crypto \
        python-pip && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/1912000/oracle-instantclient19.12-basiclite-19.12.0.0.0-1.x86_64.rpm; \
    echo "/usr/lib/oracle/19/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig
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
