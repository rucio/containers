
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

# Optional package version pinning for reproducible images.
# When APACHE2_VERSION is set, all related package versions must be provided.
# Package versions can be looked up at https://packages.ubuntu.com/ (use noble/noble-updates).
ARG APACHE2_VERSION=
ARG APACHE2_DEV_VERSION=
ARG MOD_AUTH_OPENIDC_VERSION=
ARG MOD_OAUTH2_VERSION=
ARG GRIDSITE_VERSION=

RUN set -ex; \
    apt-get update; \
    if [ -n "${APACHE2_VERSION}" ] && [ -n "${APACHE2_DEV_VERSION}" ] && [ -n "${MOD_AUTH_OPENIDC_VERSION}" ] && [ -n "${MOD_OAUTH2_VERSION}" ] && [ -n "${GRIDSITE_VERSION}" ]; then \
      apt-get install -y \
        "apache2=${APACHE2_VERSION}" \
        "apache2-dev=${APACHE2_DEV_VERSION}" \
        "libapache2-mod-auth-openidc=${MOD_AUTH_OPENIDC_VERSION}" \
        "libapache2-mod-oauth2=${MOD_OAUTH2_VERSION}" \
        "gridsite=${GRIDSITE_VERSION}" \
        qbittorrent-nox \
      ; \
    else \
      apt-get install -y \
        apache2 \
        apache2-dev \
        libapache2-mod-auth-openidc \
        libapache2-mod-oauth2 \
        gridsite \
        qbittorrent-nox \
      ; \
    fi; \
    apt-get clean

LABEL org.rucio.webdav.apache2-version="${APACHE2_VERSION}" \
      org.rucio.webdav.apache2-dev-version="${APACHE2_DEV_VERSION}" \
      org.rucio.webdav.mod-auth-openidc-version="${MOD_AUTH_OPENIDC_VERSION}" \
      org.rucio.webdav.mod-oauth2-version="${MOD_OAUTH2_VERSION}" \
      org.rucio.webdav.gridsite-version="${GRIDSITE_VERSION}"


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
