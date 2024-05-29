FROM centos:7

# Install FTS
RUN yum install -y epel-release.noarch
ADD fts3-testing.repo /etc/yum.repos.d/fts3-testing.repo
RUN curl https://fts-repo.web.cern.ch/fts-repo/fts3-depend-el7.repo >  /etc/yum.repos.d/fts3-depend-el7.repo
RUN curl https://dmc-repo.web.cern.ch/dmc-repo/dmc-el7.repo > /etc/yum.repos.d/dmc-el7.repo
RUN yum upgrade -y && \
    yum install -y centos-release-scl
RUN yum install -y \
    mysql \
    multitail \
    gfal2-plugin* \ 
    fts-libs-3.13.0-r2405271344gitc6d02cc.el7.cern.x86_64 \
    fts-server-3.13.0-r2405271344gitc6d02cc.el7.cern.x86_64 \
    fts-rest-server-3.13.0-r2405271058git798429f.el7.cern.noarch \ 
    fts-monitoring \ 
    fts-mysql-3.13.0-r2405271344gitc6d02cc.el7.cern.x86_64 \ 
    fts-msg-3.13.0-r2405271344gitc6d02cc.el7.cern.x86_64 \ 
    zeromq
RUN yum clean all

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
