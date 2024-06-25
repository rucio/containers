FROM almalinux:9

# Enable EPEL
RUN dnf install -y yum-utils \
  && dnf config-manager --set-enabled crb \
  && dnf install -y epel-release


# Install FTS
RUN curl -sSfL -o /etc/yum.repos.d/fts3.repo https://fts-repo.web.cern.ch/fts-repo/fts3-el9.repo \
  && curl -sSfL -o /etc/yum.repos.d/fts3-depend.repo https://fts-repo.web.cern.ch/fts-repo/fts3-depend.repo


RUN  dnf install -y \
  fts-server fts-mysql fts-rest-client fts-rest-server fts-monitoring \
  fts-server-selinux fts-rest-server-selinux fts-monitoring-selinux \
  fts-msg \
  mysql \
  multitail \
  gfal2-plugin*
  

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
COPY fts-msg-monitoring.conf /etc/fts3/fts-msg-monitoring.conf

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
