FROM centos:7

# Install XrootD
RUN yum install -y epel-release.noarch
RUN yum upgrade -y
RUN yum install -y xrootd xrootd-client
RUN yum clean all

# Install the Rucio CA
RUN mkdir -p /etc/grid-security/certificates
ADD ca.pem /etc/grid-security/certificates/ca.pem
RUN ln -sf /etc/grid-security/certificates/ca.pem /etc/grid-security/certificates/4380cfc7.0

# Host certificate (xrdcert.pem, xrdkey.pem)  will have to be injected here:
RUN mkdir /etc/grid-security/xrd
RUN chown xrootd:xrootd /etc/grid-security/xrd

# Create storage area
RUN mkdir /xrdrucio
RUN chown xrootd:xrootd /xrdrucio

# Server config
COPY xrdrucio.cfg /etc/xrootd/xrdrucio.cfg
EXPOSE 1094

# Startup
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
