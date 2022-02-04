# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Cedric Serfon, <cedric.serfon@cern.ch>, 2017
# - Thomas Beermann, <thomas.beermann@cern.ch>, 2018-2020

FROM centos:7

ARG TAG

WORKDIR /tmp

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum -y install https://repo.ius.io/ius-release-el7.rpm &&\
    yum install -y httpd python36u-pip python36-mod_wsgi libaio gcc python36-devel.x86_64 mod_ssl openssl-devel.x86_64 python36-m2crypto libnsl.x86_64 patch.x86_64 memcached gridsite && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN mv /etc/httpd/conf.d/zgridsite.conf /etc/httpd/conf.d/zgridsite.conf-hide
RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/1912000/oracle-instantclient19.12-basiclite-19.12.0.0.0-1.x86_64.rpm; \
    echo "/usr/lib/oracle/19/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig
RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir --upgrade setuptools
RUN rm -rf /usr/lib/python3.6/site-packages/ipaddress*
RUN python3 -m pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql]==$TAG
RUN python3 -m pip install --no-cache-dir j2cli

ADD rucio.config.default.cfg /tmp/
ADD rucio.conf.j2 /tmp/
ADD httpd.conf.j2 /tmp/
ADD 00-mpm.conf.j2 /tmp
ADD docker-entrypoint.sh /
ADD robots.txt /var/www/html
RUN rm /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/ssl.conf
RUN mkdir -p /var/log/rucio/trace && chown apache:apache /var/log/rucio/trace
RUN mkdir -p /var/log/rucio/nongrid_trace && chown apache:apache /var/log/rucio/nongrid_trace

VOLUME /var/log/httpd
VOLUME /opt/rucio/etc

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/docker-entrypoint.sh"]
