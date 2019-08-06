FROM centos:7

RUN yum install -y epel-release.noarch
RUN yum upgrade -y
RUN yum install -y supervisor xrootd xrootd-client

RUN mkdir -p /server1 /tmp/server1 /etc/xrootd/server1
RUN chown xrootd:xrootd /server1 /tmp/server1 /etc/xrootd/server1
COPY xrootd-server1.cfg /etc/xrootd/xrootd-server1.cfg

RUN mkdir -p /server2 /tmp/server2 /etc/xrootd/server2
RUN chown xrootd:xrootd /server2 /tmp/server2 /etc/xrootd/server2
COPY xrootd-server2.cfg /etc/xrootd/xrootd-server2.cfg

RUN mkdir -p /server3 /tmp/server3 /etc/xrootd/server3
RUN chown xrootd:xrootd /server3 /tmp/server3 /etc/xrootd/server3
COPY xrootd-server3.cfg /etc/xrootd/xrootd-server3.cfg

EXPOSE 1094 1095 1096

COPY supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisord.conf"]
