# Copyright 2017-2022 CERN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM almalinux:9

ARG TAG="master"

WORKDIR /

RUN dnf -y install yum-utils epel-release.noarch && \
    yum-config-manager --enable crb && \
    dnf -y install \
        gcc \
        git \
        gfal2-all \
        python3-gfal2-util \
        python3-gfal2 \
        gmp-devel \
        gridsite \
        httpd \
        krb5-devel \
        libaio \
        libtool-ltdl-devel \
        libxml2-devel \
        mariadb-connector-c \
        memcached \
        mod_ssl \
        mod_auth_gssapi \
        multitail \
        nmap-ncat \
        openssh-clients \
        openssl-devel \
        python3-setuptools \
        python3-pip \
        python3-devel \
        python3-mod_wsgi \
        python3-m2crypto \
        rsync \
        unzip \
        vim \
        voms-clients-java \
        which \
        xmlsec1-devel \
        xmlsec1-openssl-devel \
        xrootd-client && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN curl https://rclone.org/install.sh | bash

RUN git clone --depth 1 --branch "$TAG" https://github.com/rucio/rucio.git /tmp/rucio && rm -rf /tmp/rucio/.git

ENV RUCIOHOME=/opt/rucio
RUN mkdir -p $RUCIOHOME && \
    mkdir -p $RUCIOHOME/etc/multi_vo/tst/etc && \
    mkdir -p $RUCIOHOME/etc/multi_vo/ts2/etc
WORKDIR $RUCIOHOME
RUN mkdir -p \
      bin \
      etc \
      lib/rucio \
      tools

RUN python3 -m pip install --no-cache --upgrade pip && \
    python3 -m pip install --no-cache --upgrade setuptools wheel && \
    python3 -m pip install --no-cache --upgrade -r /tmp/rucio/requirements/requirements.dev.txt ; \
    ln -s $RUCIOHOME/lib/rucio /usr/local/lib/python3.9/site-packages/rucio

RUN python3 -m pip install --no-cache --upgrade fts3

COPY .pep8 .pep8
COPY .flake8 .flake8
COPY pylintrc etc/pylintrc
RUN cp -r /tmp/rucio/etc . && \
    cp -r /tmp/rucio/tools . && \
    mkdir /var/log/rucio /var/log/rucio/trace && \
    chmod -R 777 /var/log/rucio

COPY rucio.cfg alembic.ini google-cloud-storage-test.json $RUCIOHOME/etc/
COPY rucio_multi_vo_tst.cfg $RUCIOHOME/etc/multi_vo/tst/etc/rucio.cfg
COPY rucio_multi_vo_ts2.cfg $RUCIOHOME/etc/multi_vo/ts2/etc/rucio.cfg
COPY rclone-init.cfg $RUCIOHOME/etc/rclone-init.cfg

COPY 00-mpm.conf /etc/httpd/conf.modules.d/00-mpm.conf
COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY rucio.conf /etc/httpd/conf.d/rucio.conf
RUN mkdir /root/.ssh && \
    chmod 700 /root/.ssh && echo "Host ssh1" > /root/.ssh/config && \
    echo "IdentityFile /root/.ssh/ruciouser_sshkey" >> /root/.ssh/config

RUN chmod 777 /var/log/rucio/trace && \
    rm -rf $RUCIOHOME/tools && \
    mkdir -p $RUCIOHOME/tools && \
    mkdir -p /etc/httpd && \
    echo "" > /etc/httpd/conf.d/ssl.conf && \
    echo "" > /etc/httpd/conf.d/autoindex.conf && \
    echo "" > /etc/httpd/conf.d/userdir.conf && \
    echo "" > /etc/httpd/conf.d/welcome.conf && \
    echo "" > /etc/httpd/conf.d/zgridsite.conf

COPY logshow restartweb run_daemons create_monit_data /usr/local/bin/
COPY monit-entrypoint.sh /monit-entrypoint.sh

COPY dashboards/* $RUCIOHOME/etc/dashboards/
COPY rse_repository.json $RUCIOHOME/etc/rse_repository.json

RUN rm -r /tmp/rucio && \
    chmod +x /usr/local/bin/logshow && \
    chmod +x /usr/local/bin/restartweb && \
    chmod +x /usr/local/bin/run_daemons && \
    chmod +x /usr/local/bin/create_monit_data && \
    chmod +x $RUCIOHOME/etc/dashboards/import_dashboards.sh && \
    chmod +x /monit-entrypoint.sh && \
    ln -fs /usr/bin/python3 /usr/bin/python

RUN update-crypto-policies --set DEFAULT:SHA1

EXPOSE 443
ENV PATH $PATH:$RUCIOHOME/bin
RUN mkdir /tmp/prometheus && chown apache:apache /tmp/prometheus/
ENV PROMETHEUS_MULTIPROC_DIR /tmp/prometheus
CMD ["httpd","-D","FOREGROUND"]
