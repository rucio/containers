FROM centos:7

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
COPY xrdrucio.cfg /etc/xrootd/xrdrucio.cfg

# Startup
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
