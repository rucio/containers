FROM docker.io/almalinux:9

# Install CERN CA
ADD ca.repo /etc/yum.repos.d/ca.repo

# WLCG repo is the same for x86_64 and aarch64
RUN dnf install -y epel-release.noarch https://linuxsoft.cern.ch/wlcg/el9/x86_64/wlcg-repo-1.0.0-1.el9.noarch.rpm && \
    dnf update -y && \
    dnf upgrade -y && \
    dnf --disablerepo="*" --enablerepo="carepo" -y install 'ca*' && \
    dnf install -y xrootd xrootd-client xrootd-scitokens qbittorrent-nox && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Host certificate directory
RUN mkdir -p /etc/grid-security/certificates
RUN mkdir -p /etc/grid-security/xrd
RUN chown -R xrootd:xrootd /etc/grid-security/xrd

# Create storage area
RUN mkdir /rucio
RUN chown xrootd:xrootd /rucio

RUN update-crypto-policies --set DEFAULT:SHA1

# Server config
ADD xrdrucio.cfg /etc/xrootd/xrdrucio.cfg
ADD xrdadler32.sh /usr/local/bin/xrdadler32.sh
RUN chmod 0755 /usr/local/bin/xrd*

# Startup
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
