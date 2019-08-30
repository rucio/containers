# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Thomas Beermann, <thomas.beermann@cern.ch>, 2019

FROM centos:7

WORKDIR /tmp
ADD oic.rpm /tmp

RUN yum install -y epel-release.noarch
RUN yum upgrade -y
RUN yum install -y httpd mod_wsgi python-pip libaio gcc python-devel.x86_64 mod_ssl  openssl-devel.x86_64

RUN rpm -i /tmp/oic.rpm; \
    echo "/usr/lib/oracle/12.2/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig
RUN pip install --upgrade pip setuptools
RUN rm -rf /usr/lib/python2.7/site-packages/ipaddress*
RUN pip install --pre rucio_webui[oracle,mysql,postgresql]
RUN pip install j2cli psycopg2-binary
# only necessary temporarily until setup.py for webui is fixed
RUN pip install cx_oracle==6.3.1 PyMySQL

ADD rucio.cfg.j2 /tmp/
ADD rucio.conf.j2 /tmp/
ADD httpd.conf.j2 /tmp/
ADD 00-mpm.conf.j2 /tmp
ADD docker-entrypoint.sh /
RUN rm /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/ssl.conf

VOLUME /var/log/httpd
VOLUME /opt/rucio/etc
VOLUME /etc/grid-security

EXPOSE 443

ENTRYPOINT ["/docker-entrypoint.sh"]
