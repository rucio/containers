FROM almalinux:9

# Install CERN CA
ADD ca.repo /etc/yum.repos.d/ca.repo

RUN dnf install -y epel-release.noarch http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN dnf update -y && \
    dnf upgrade -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN dnf --disablerepo="*" --enablerepo="carepo" -y install 'ca*' && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Install XrootD
RUN dnf install -y epel-release.noarch
RUN dnf upgrade -y
RUN dnf install -y xrootd xrootd-client
RUN dnf clean all

# Host certificate directory
RUN mkdir -p /etc/grid-security/certificates
RUN mkdir -p /etc/grid-security/xrd
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
