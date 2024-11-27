
FROM ubuntu:noble as deb_builder
RUN set -ex; \
    apt-get update; \
    apt-get install -y \
      apache2-dev \
      apache2-ssl-dev \
      build-essential \
      curl \
      libaprutil1-dev \
      libapr1-dev \
      libtool \
      zlib1g-dev

COPY libapache2-mod-want-digest/ mod-want-digest/
RUN cd mod-want-digest/; dpkg-buildpackage

COPY libapache2-mod-gsiproxy mod-gsiproxy
RUN cd mod-gsiproxy; dpkg-buildpackage


FROM ubuntu:noble

RUN set -ex; \
    apt-get update; \
    apt-get install -y \
      apache2 \
      apache2-dev \
      libapache2-mod-auth-openidc \
      libapache2-mod-oauth2 \
      gridsite \
      qbittorrent-nox \
    ; \
    apt-get clean


# Configure apache
COPY conf/ conf/
RUN set -ex; \
    cp -R conf/* /etc/apache2/; \
    # Create directory for webdav
    mkdir -p /var/www/webdav/digests /var/www/webdav/data; \
    chown -R www-data:www-data /var/www/webdav; \
    \
    a2enmod dav dav_fs auth_basic auth_digest auth_openidc alias headers mime setenvif; \
    a2dismod zgridsite; \
    a2dissite 000-default

# Install compiled modules
COPY --from=deb_builder /*.deb /tmp/
RUN dpkg -i /tmp/*.deb

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
EXPOSE 80/tcp 443/tcp
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["apache2","-D","FOREGROUND"]
