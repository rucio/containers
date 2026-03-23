FROM almalinux:9

# Enable EPEL
RUN dnf install -y yum-utils \
  && dnf config-manager --set-enabled crb \
  && dnf install -y epel-release \
  && dnf clean all \
  && rm -rf /var/cache/dnf


# Install FTS

# Get repos (DMC is needed for GFAL2)
RUN curl -sSfL -o /etc/yum.repos.d/fts3.repo https://fts-repo.web.cern.ch/fts-repo/fts3-el9.repo \
  && curl -sSfL -o /etc/yum.repos.d/fts3-depend.repo https://fts-repo.web.cern.ch/fts-repo/fts3-depend.repo \
  && curl -sSfL -o /etc/yum.repos.d/dmc.repo https://dmc-repo.web.cern.ch/dmc-repo/dmc-el9.repo

# Optional version pinning for reproducible images.
# When all FTS version args are provided, we install pinned RPM versions to
# make the image deterministic. If not provided, we fall back to unpinned
# latest installs, matching the historical behavior of docker-auto-build.yml workflow.
# These arguments can be overridden at the build time by the service-versioned workflow.
# Version arguments can be taken from production builds in
# https://fts-repo.web.cern.ch/fts-repo/el9/x86_64/
ARG FTS_SERVER_VERSION=
ARG FTS_REST_VERSION=
ARG FTS_MONITORING_VERSION=

# python3-django3 was removed from EPEL 9 after Django 3.2 EOL (April 2024),
# but fts-monitoring still requires it. Install directly from Fedora Koji where
# the build is archived.
RUN dnf install -y \
    https://kojipkgs.fedoraproject.org/packages/python-django3/3.2.25/1.el9/noarch/python3-django3-3.2.25-1.el9.noarch.rpm \
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN if [ -n "${FTS_SERVER_VERSION}" ] && [ -n "${FTS_REST_VERSION}" ] && [ -n "${FTS_MONITORING_VERSION}" ]; then \
      dnf install -y \
        "fts-server-${FTS_SERVER_VERSION}" \
        "fts-mysql-${FTS_SERVER_VERSION}" \
        "fts-rest-client-${FTS_REST_VERSION}" \
        "fts-rest-server-${FTS_REST_VERSION}" \
        "fts-monitoring-${FTS_MONITORING_VERSION}" \
        "fts-server-selinux-${FTS_SERVER_VERSION}" \
        "fts-rest-server-selinux-${FTS_REST_VERSION}" \
        "fts-monitoring-selinux-${FTS_MONITORING_VERSION}" \
        fts-msg \
        mysql \
        multitail \
        gfal2-plugin* ; \
    else \
      dnf install -y \
        fts-server \
        fts-mysql \
        fts-rest-client \
        fts-rest-server \
        fts-monitoring \
        fts-server-selinux \
        fts-rest-server-selinux \
        fts-monitoring-selinux \
        fts-msg \
        mysql \
        multitail \
        gfal2-plugin* ; \
    fi \
  && dnf clean all \
  && rm -rf /var/cache/dnf
  

COPY fts3config /etc/fts3/fts3config
RUN chmod +x /usr/share/fts/fts-database-upgrade.py

# Configuration for FTSREST and FTSMON
COPY fts3rest.conf /etc/httpd/conf.d/fts3rest.conf
COPY fts3restconfig /etc/fts3/fts3restconfig
RUN \
     echo "" > /etc/httpd/conf.d/ssl.conf \
  && echo "" > /etc/httpd/conf.d/autoindex.conf \
  && echo "" > /etc/httpd/conf.d/userdir.conf \
  && echo "" > /etc/httpd/conf.d/welcome.conf \
  && echo "" > /etc/httpd/conf.d/zgridsite.conf \
  && mkdir -p /etc/grid-security/certificates

# FTS monitoring ActiveMQ configuration
COPY fts-activemq.conf /etc/fts3/fts-activemq.conf

# Entrypoint waiting script for MySQL
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Shortcut for logfiles
COPY logshow /usr/local/bin/logshow
RUN chmod +x /usr/local/bin/logshow
RUN touch /var/log/fts3/fts3server.log
RUN chown -R fts3:fts3 /var/log/fts3/fts3server.log
RUN touch /var/log/fts3rest/fts3rest.log
RUN chown -R fts3:fts3 /var/log/fts3rest

# Startup
EXPOSE 8446 8449
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
