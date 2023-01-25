FROM centos:7

# Install CERN CA
ADD ca.repo /etc/yum.repos.d/ca.repo

RUN yum install -y epel-release.noarch http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN yum update -y && \
    yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN yum -y install ca-certificates.noarch lcg-CA ca_* \
    yum clean all && \
    rm -rf /var/cache/yum

# Install XrootD
RUN yum install -y epel-release.noarch
RUN yum upgrade -y
RUN yum install -y xrootd xrootd-client
RUN yum clean all

# Install the Rucio CA
RUN mkdir -p /etc/grid-security/certificates
ADD rucio_ca.pem /etc/grid-security/certificates/5fca1cb1.0

# Host certificate directory
RUN mkdir /etc/grid-security/xrd
RUN chown -R xrootd:xrootd /etc/grid-security/xrd

# Create storage area
RUN mkdir /rucio
RUN chown xrootd:xrootd /rucio

# Server config
ADD xrdrucio.cfg /etc/xrootd/xrdrucio.cfg
ADD xrdadler32.sh /usr/local/bin/xrdadler32.sh
RUN chmod 0755 /usr/local/bin/xrd*

# Startup
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
