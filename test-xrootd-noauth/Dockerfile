FROM almalinux:9

# Optional version pinning for reproducible images.
# When `XROOTD_VERSION` is provided (e.g. `5.9.1-1.el9`), we install
# `xrootd*` packages with explicit RPM versions to make the image
# deterministic. If not provided, we fall back to unpinned installs,
# matching the historical behavior.
ARG XROOTD_VERSION=

RUN dnf install -y epel-release.noarch && \
    dnf update -y && \
    dnf upgrade -y && \
    if [ -n "${XROOTD_VERSION}" ]; then \
      dnf install -y \
        "xrootd-${XROOTD_VERSION}" \
        "xrootd-client-${XROOTD_VERSION}" ; \
    else \
      dnf install -y xrootd xrootd-client ; \
    fi && \
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
