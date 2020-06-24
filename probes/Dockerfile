# Copyright European Organization for Nuclear Research (CERN) 2020
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Eric Vaandering, <ewv@fnal.gov>, 2020

FROM centos:7

WORKDIR /tmp
ADD oic.rpm /tmp

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum install -y python-pip libaio gcc python-devel.x86_64 openssl-devel.x86_64 MySQL-python git && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN rpm -i /tmp/oic.rpm; \
    echo "/usr/lib/oracle/12.2/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig

RUN rpm -i https://github.com/dshearer/jobber/releases/download/v1.4.0/jobber-1.4.0-1.el7.x86_64.rpm

RUN pip install --no-cache-dir --upgrade pip setuptools
RUN rm -rf /usr/lib/python2.7/site-packages/ipaddress*
RUN pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql]
RUN pip install --no-cache-dir j2cli psycopg2-binary
RUN pip install --no-cache-dir cx_oracle==6.3.1 PyMySQL

WORKDIR /
RUN git clone https://github.com/rucio/probes.git

ADD rucio.cfg.j2 /tmp/

ADD run-probes.sh /

ENTRYPOINT ["/run-probes.sh"]
