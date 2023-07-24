FROM almalinux:9

RUN dnf install -y epel-release.noarch && \
    dnf update -y && \
    dnf upgrade -y && \
    dnf install -y xrootd xrootd-client && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Host certificate directory
RUN mkdir -p /etc/grid-security/xrd
RUN mkdir -p /etc/grid-security/certificates
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
