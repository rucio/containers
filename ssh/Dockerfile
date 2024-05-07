FROM almalinux:9

RUN dnf install -y epel-release.noarch && \
    dnf upgrade -y && \
    dnf install -y \
        gcc \
        openssh-server \
        openssh-clients \
        python-pip \
        rsync \
        sudo \
        unzip && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN curl https://rclone.org/install.sh | bash
RUN python3 -m pip install -U dumb-init

# Server config
RUN /usr/bin/ssh-keygen -A && \
    echo '' > /tmp/sshkey.pub
COPY sshd_config /etc/ssh/sshd_config

# Create storage area
RUN mkdir /rucio /root/.ssh && \
    echo '' > /root/.ssh/authorized_keys

# Startup
EXPOSE 22
ADD docker-entrypoint.sh /
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"] 
CMD ["/bin/bash", "/docker-entrypoint.sh"]
