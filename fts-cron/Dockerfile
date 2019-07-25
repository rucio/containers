FROM centos:7

# Repos needed for (VOMS and FTS) and WLCG certs
RUN curl -o  /etc/yum.repos.d/ca.repo https://raw.githubusercontent.com/rucio/rucio/master/etc/docker/dev/ca.repo

RUN yum install -y epel-release.noarch http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN yum update -y && \
    yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum

# Install latest kubectl
RUN curl -o /usr/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x /usr/bin/kubectl

# Install VOMS and FTS clients for delegating proxies
RUN yum -y install ca-certificates.noarch lcg-CA voms-clients-cpp fts-rest-cli \
    wlcg-voms-cms wlcg-voms-atlas \
    python-pip python-setuptools python-requests && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN pip install --upgrade pip setuptools
RUN pip install j2cli

RUN mkdir -p /opt/rucio/certs/
RUN mkdir -p /opt/rucio/kubeconfig/

ADD docker-entrypoint.sh /
ADD renew_fts_proxy.sh.j2 /
ADD renew_fts_proxy_atlas.sh.j2 /
ADD renew_fts_proxy_dteam.sh.j2 /

ADD dteam* /etc/vomses/

ENTRYPOINT ["/docker-entrypoint.sh"]
