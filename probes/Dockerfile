# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Eric Vaandering, <ewv@fnal.gov>, 2019

FROM rucio/rucio-daemons:latest

RUN yum install -y git \
    && yum clean all && rm -rf /var/cache/yum

ADD run-probes.sh /

WORKDIR /
RUN git clone https://github.com/rucio/probes.git

ENTRYPOINT ["/run-probes.sh"]
