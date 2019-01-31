FROM centos:7

RUN yum install -y epel-release.noarch
RUN yum install -y python-pip
RUN yum install -y voms-clients-java
RUN yum install -y gfal2-all gfal2-util
RUN yum install -y nordugrid-arc-client nordugrid-arc-plugins-gfal \
                   nordugrid-arc-plugins-globus nordugrid-arc-plugins-s3 \
                   nordugrid-arc-plugins-xrootd

# Upgrade pip & setuptools
RUN pip install --upgrade setuptools
RUN pip install --upgrade pip

# Install Rucio
RUN pip install rucio-clients
RUN pip install jinja2 j2cli pyyaml

COPY rucio.cfg.j2 /

# To generate the configuration and enable bash completion for the rucio clients
ADD bashrc /root/.bashrc

ENV PATH $PATH:/opt/rucio/bin

CMD ["/bin/bash"]
