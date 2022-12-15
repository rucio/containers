FROM centos:7

# Install FTS
RUN yum install -y epel-release.noarch
RUN curl https://fts-repo.web.cern.ch/fts-repo/fts3-prod-el7.repo > /etc/yum.repos.d/fts3-prod-el7.repo
RUN curl https://fts-repo.web.cern.ch/fts-repo/fts3-depend-el7.repo >  /etc/yum.repos.d/fts3-depend-el7.repo
RUN curl https://dmc-repo.web.cern.ch/dmc-repo/dmc-el7.repo > /etc/yum.repos.d/dmc-el7.repo
RUN yum upgrade -y && \
    yum install -y centos-release-scl
RUN yum install -y mysql multitail gfal2-plugin* fts-server fts-client fts-rest-server fts-monitoring fts-mysql fts-msg
RUN yum clean all

# Setup FTS security
COPY certs/hostcert_fts.pem /etc/grid-security/hostcert.pem
COPY certs/hostcert_fts.key.pem /etc/grid-security/hostkey.pem
COPY certs/rucio_ca.pem /etc/grid-security/certificates/5fca1cb1.0
RUN chmod 400 /etc/grid-security/hostkey.pem

# Database configuration for FTS server
COPY fts3config /etc/fts3/fts3config
RUN chmod +x /usr/share/fts/fts-database-upgrade.py

# Configuration for FTSREST and FTSMON
COPY fts3rest.conf /etc/httpd/conf.d/fts3rest.conf
COPY fts3restconfig /etc/fts3/fts3restconfig
RUN echo "" > /etc/httpd/conf.d/ssl.conf &&\
    echo "" > /etc/httpd/conf.d/autoindex.conf &&\
    echo "" > /etc/httpd/conf.d/userdir.conf &&\
    echo "" > /etc/httpd/conf.d/welcome.conf &&\
    echo "" > /etc/httpd/conf.d/zgridsite.conf

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
