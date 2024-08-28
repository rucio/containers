ARG TAG
FROM rucio/rucio-clients:release-$TAG

USER root
RUN dnf install -y git cmake3 libcurl-devel fuse-devel tree g++

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/opt/rh/devtoolset-9/root/usr/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable

ARG CACHEBUST=12
WORKDIR /opt
RUN git clone --recursive https://github.com/rucio/fuse-posix.git
WORKDIR /opt/fuse-posix
RUN /bin/bash ./build.sh

ENV PATH $PATH:/opt/rucio/bin
RUN pip3 install argcomplete
RUN /etc/profile.d/rucio_init.sh

RUN mkdir /ruciofs
RUN mkdir /ruciofs-cache
ENV RUCIOFS_SETTINGS_FILES_ROOT /ruciofs-settings
RUN mkdir /ruciofs-settings
VOLUME "/ruciofs-cache"

ENV PATH $PATH:/opt/fuse-posix/cmake-build-debug/bin

CMD ["rucio-fuse-main", "-vv"]
