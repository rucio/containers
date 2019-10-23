# Copyright 2017-2019 CERN for the benefit of the ATLAS collaboration.
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
#
# Authors:
# - Thomas Beermann <thomas.beermann@cern.ch>, 2017-2019
# - Vincent Garonne <vgaronne@gmail.com>, 2017-2019
# - Cedric Serfon <cedric.serfon@cern.ch>, 2017
# - Frank Berghaus <frank.berghaus@cern.ch>, 2017-2018
# - Mario Lassnig <mario.lassnig@cern.ch>, 2019

FROM centos:7

RUN yum -y update
RUN yum install -y epel-release
RUN yum install -y \
      gcc \
      httpd \
      mod_ssl \
      mod_auth_kerb \
      mod_wsgi \
      python \
      python-pip \
      python-devel \
      gmp-devel \
      krb5-devel \
      git \
      openssl-devel \
      gridsite \
      which \
      libaio \
      memcached \
      nmap-ncat \
      gfal2-all \
      gfal2-util \
      fts-rest-cli \
      xrootd-client \
      multitail
RUN yum clean all

RUN git clone https://github.com/rucio/rucio.git /tmp/rucio

ENV RUCIOHOME=/opt/rucio
RUN mkdir -p $RUCIOHOME
WORKDIR $RUCIOHOME
RUN mkdir -p \
      bin \
      etc \
      lib/rucio \
      tools

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN rm -rf /usr/lib/python2.7/site-packages/ipaddress*
RUN pip install -r /tmp/rucio/tools/pip-requires-client
RUN pip install -r /tmp/rucio/tools/pip-requires
RUN pip install -r /tmp/rucio/tools/pip-requires-test
RUN pip install psycopg2-binary
RUN ln -s $RUCIOHOME/lib/rucio /usr/lib/python2.7/site-packages/rucio

COPY .pep8 .pep8
COPY .flake8 .flake8
COPY pylintrc etc/pylintrc
RUN cp -r /tmp/rucio/etc .
RUN cp -r /tmp/rucio/tools .

RUN mkdir /var/log/rucio /var/log/rucio/trace
RUN chmod -R 777 /var/log/rucio

COPY rucio.cfg $RUCIOHOME/etc/rucio.cfg
COPY alembic.ini $RUCIOHOME/etc/alembic.ini
COPY aliases-py27.conf $RUCIOHOME/etc/web/aliases-py27.conf
COPY ui-aliases-py27.conf $RUCIOHOME/etc/web/ui-aliases-py27.conf
COPY google-cloud-storage-test.json $RUCIOHOME/etc/google-cloud-storage-test.json
COPY certs/rucio_ca.pem /etc/grid-security/certificates/5fca1cb1.0

COPY 00-mpm.conf /etc/httpd/conf.modules.d/00-mpm.conf
COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY rucio.conf /etc/httpd/conf.d/rucio.conf
COPY certs/ruciouser.pem $RUCIOHOME/etc/usercert.pem
COPY certs/ruciouser.key.pem $RUCIOHOME/etc/userkey.pem
COPY certs/ruciouser.certkey.pem $RUCIOHOME/etc/usercertkey.pem
RUN chmod 0400 $RUCIOHOME/etc/userkey.pem

COPY certs/hostcert_rucio.pem /etc/grid-security/hostcert.pem
COPY certs/hostcert_rucio.key.pem /etc/grid-security/hostkey.pem
RUN chmod 0400 /etc/grid-security/hostkey.pem

RUN chmod 777 /var/log/rucio/trace
RUN rm -rf $RUCIOHOME/tools
RUN mkdir -p $RUCIOHOME/tools
RUN mkdir -p /etc/httpd
RUN echo "" > /etc/httpd/conf.d/ssl.conf &&\
    echo "" > /etc/httpd/conf.d/autoindex.conf &&\
    echo "" > /etc/httpd/conf.d/userdir.conf &&\
    echo "" > /etc/httpd/conf.d/welcome.conf &&\
    echo "" > /etc/httpd/conf.d/zgridsite.conf

RUN rm -r /tmp/rucio

COPY logshow /usr/local/bin/logshow
RUN chmod +x /usr/local/bin/logshow

COPY restartweb /usr/local/bin/restartweb
RUN chmod +x /usr/local/bin/restartweb

COPY run_daemons /usr/local/bin/run_daemons
RUN chmod +x /usr/local/bin/run_daemons
COPY create_monit_data /usr/local/bin/create_monit_data
RUN chmod +x /usr/local/bin/create_monit_data

RUN mkdir $RUCIOHOME/etc/dashboards
COPY dashboards/* $RUCIOHOME/etc/dashboards/
RUN chmod +x $RUCIOHOME/etc/dashboards/import_dashboards.sh
COPY monit-entrypoint.sh /monit-entrypoint.sh
RUN chmod +x /monit-entrypoint.sh

EXPOSE 443

ENV PATH $PATH:$RUCIOHOME/bin

CMD ["httpd","-D","FOREGROUND"]
