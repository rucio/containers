FROM centos:7

ARG TAG

RUN yum install -y epel-release.noarch && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum -y install https://repo.ius.io/ius-release-el7.rpm && \
    yum install -y python36u-pip voms-clients-java gfal2-all gfal2-util python3-gfal2 xrootd-client\
                   nordugrid-arc-client nordugrid-arc-plugins-gfal \
                   nordugrid-arc-plugins-globus nordugrid-arc-plugins-s3 \
                   nordugrid-arc-plugins-xrootd && \
    yum clean all && \
    rm -rf /var/cache/yum

# Upgrade pip & setuptools and install Rucio
RUN python3.6 -m pip install --no-cache-dir --upgrade pip && \
    python3.6 -m pip install  --no-cache-dir --upgrade setuptools && \
    python3.6 -m pip install --no-cache-dir --pre rucio-clients[argcomplete]==$TAG && \
    python3.6 -m pip install --no-cache-dir jinja2 j2cli pyyaml


# Add a separate user and change ownership of config dir to that user
RUN groupadd -g 1000 user && \
    useradd -ms /bin/bash -u 1000 -g 1000 user && \
    mkdir -p /opt/rucio/etc/ && \
    chown -R user:user /opt/rucio/etc/ && \
    mkdir -p /opt/user && \
    chown user:user /opt/user

USER user
WORKDIR /home/user

# Add the configuration template and enable bash completion for the rucio clients
ADD --chown=user:user rucio.cfg.j2 /opt/user/rucio.cfg.j2
ADD init_rucio.sh /etc/profile.d/rucio_init.sh

ENV PATH $PATH:/opt/rucio/bin

CMD ["/bin/bash"]
