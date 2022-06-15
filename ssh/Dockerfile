FROM centos:7

# Install OpenSSH
RUN yum install -y epel-release.noarch
RUN yum upgrade -y
RUN yum -y install gcc openssh-server openssh-clients sudo python3-pip && \
    pip3 install -U dumb-init && \
    yum -y install rsync && \
    yum -y install rclone
RUN yum clean all && \
    rm -rf /var/cache/yum

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
