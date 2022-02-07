FROM centos:7

ARG TAG

WORKDIR /tmp
ADD oic.rpm /tmp

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum install -y python-pip libaio gcc python-devel.x86_64 openssl-devel.x86_64 MySQL-python memcached && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN rpm -i /tmp/oic.rpm; \
    echo "/usr/lib/oracle/12.2/client64/lib" >/etc/ld.so.conf.d/oracle.conf; \
    ldconfig
RUN pip install --no-cache-dir --upgrade "pip < 21.0"
RUN pip install --no-cache-dir --upgrade "setuptools < 45"
RUN rm -rf /usr/lib/python2.7/site-packages/ipaddress*
RUN pip install --no-cache-dir --pre rucio[oracle,mysql,postgresql]==$TAG
RUN pip install jinja2 j2cli pyyaml

RUN mkdir -p /opt/rucio/etc

COPY rucio.cfg.j2 /tmp
COPY alembic.ini.j2 /tmp
COPY bootstrap.py /tmp
COPY docker-entrypoint.sh /

CMD ["/docker-entrypoint.sh"]
