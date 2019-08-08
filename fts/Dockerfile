FROM centos:7

# Install FTS
RUN yum install -y epel-release.noarch
RUN yum upgrade -y
RUN yum install -y fts-server fts-client fts-rest fts-monitoring fts-mysql fts-msg gfal2-plugin-* mysql
RUN yum clean all

# Setup FTS security
COPY certs/fts.crt /etc/grid-security/hostcert.pem
COPY certs/fts.key.pem /etc/grid-security/hostkey.pem
COPY certs/ca.pem /etc/grid-security/certificates/ca.pem
RUN ln -sf /etc/grid-security/certificates/ca.pem /etc/grid-security/certificates/4380cfc7.0
RUN chmod 400 /etc/grid-security/hostkey.pem

# Database configuration for FTS server
COPY fts3config /etc/fts3/fts3config
RUN chmod +x /usr/share/fts/fts-database-upgrade.py

# Configuration for FTSREST and FTSMON
COPY fts3rest.conf /etc/httpd/conf.d/fts3rest.conf
RUN echo "" > /etc/httpd/conf.d/ssl.conf &&\
    echo "" > /etc/httpd/conf.d/autoindex.conf &&\
    echo "" > /etc/httpd/conf.d/userdir.conf &&\
    echo "" > /etc/httpd/conf.d/welcome.conf &&\
    echo "" > /etc/httpd/conf.d/zgridsite.conf

# Entrypoint waiting script for MySQL
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Startup
EXPOSE 8446 8449
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
