FROM almalinux:9

ARG OPENSSH_SERVER_VERSION=
ARG OPENSSH_CLIENTS_VERSION=

RUN dnf install -y epel-release.noarch && \
    dnf upgrade -y && \
    if [ -n "${OPENSSH_SERVER_VERSION}" ] && [ -n "${OPENSSH_CLIENTS_VERSION}" ]; then \
      dnf install -y \
        gcc \
        "openssh-server-${OPENSSH_SERVER_VERSION}" \
        "openssh-clients-${OPENSSH_CLIENTS_VERSION}" \
        python-pip \
        rsync \
        sudo \
        unzip ; \
    else \
      dnf install -y \
        gcc \
        openssh-server \
        openssh-clients \
        python-pip \
        rsync \
        sudo \
        unzip ; \
    fi && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN curl https://rclone.org/install.sh | bash
RUN python3 -m pip install -U dumb-init

LABEL org.rucio.ssh.openssh-server-version="${OPENSSH_SERVER_VERSION}" \
      org.rucio.ssh.openssh-clients-version="${OPENSSH_CLIENTS_VERSION}"

# Server config
RUN /usr/bin/ssh-keygen -A && \
    echo '' > /tmp/sshkey.pub
COPY sshd_config /etc/ssh/sshd_config

# Create storage area
RUN mkdir -p /rucio && \
    mkdir -p /root/.ssh && \
    echo '' > /root/.ssh/authorized_keys

# Startup
EXPOSE 22
ADD docker-entrypoint.sh /
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"] 
CMD ["/bin/bash", "/docker-entrypoint.sh"]
