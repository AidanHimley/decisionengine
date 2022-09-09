# SPDX-FileCopyrightText: 2017 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# on dockerhub hepcloud/decision-engine-ci
#    The CI container should probably come from modules...
FROM sl:7
LABEL description="hepcloud/decision-engine-framework"

# You can select another version at container build time by setting
# this value to the expected version - ie 9.6
ENV PG_VERSION=12
ARG PG_VERSION=12

# Set where to collect metrics "on disk"
ENV PROMETHEUS_MULTIPROC_DIR=/tmp

# If you want to run decisionengine in this container
# you'll need to bind mount onto these points
RUN mkdir -m 750 -p /var/log/decisionengine ; \
    mkdir -m 750 -p /etc/decisionengine

# Extra repos we need
RUN yum install -y http://ftp.scientificlinux.org/linux/scientific/7x/repos/x86_64/yum-conf-softwarecollections-2.0-1.el7.noarch.rpm \
 && yum -y clean all
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && yum -y clean all

# set PATH for build and runtime
ENV PATH="/usr/pgsql-${PG_VERSION}/bin:~/.local/bin:$PATH"
ARG PATH="/usr/pgsql-${PG_VERSION}/bin:~/.local/bin:$PATH"

# Install postgresql-${PG_VERSION}
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
 && yum -y clean all
RUN yum -y install postgresql$(echo -n ${PG_VERSION} | tr -d '.')-server \
                   postgresql$(echo -n ${PG_VERSION} | tr -d '.')-devel \
                   postgresql$(echo -n ${PG_VERSION} | tr -d '.') \
 && yum -y clean all

# Install redis 5 server and tools
RUN yum install -y rh-redis5

# Install utils
RUN yum -y install \
    python3 python3-pip python3-setuptools python3-wheel \
    gcc gcc-c++ make python3-devel swig openssl-devel \
    git \
    rpm-build \
 && yum -y clean all

# Ensure pip/setuptools are up to date
#  rpm-build requires libraries in /usr
RUN python3 -m pip install --upgrade --prefix=/usr pip ; \
    python3 -m pip install --upgrade --prefix=/usr setuptools wheel setuptools-scm[toml]

# Install decisionengine requirements (runtime and testing)
#  do as one layer to simplify merges
#  rpm-build requires libraries in /usr
RUN su - adm -s /bin/bash -c "git clone https://github.com/HEPCloud/decisionengine.git /tmp/decisionengine.git"; \
    cd /tmp/decisionengine.git ; \
    su adm -s /bin/bash -c "cd /tmp/decisionengine.git ; python3 setup.py bdist_wheel" ; \
    python3 -m pip install --prefix=/usr dist/*.whl ; \
    python3 -m pip install --prefix=/usr decisionengine[develop] ; \
    python3 -m pip uninstall -y decisionengine ; \
    rm -rf /tmp/decisionengine.git

# Install minimal glideinwms
RUN yum -y install \
        yum-priorities \
        https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm; \
    sed -i '0,/enabled/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/osg-upcoming.repo; \
    sed -i '0,/enabled/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/osg-contrib.repo; \
    sed -i '0,/enabled/{s/enabled=1/enabled=1\npriority=99/}' /etc/yum.repos.d/epel.repo; \
    yum -y install \
        glideinwms-vofrontend-libs \
        glideinwms-vofrontend-glidein voms-clients-cpp osg-ca-certs \
        fetch-crl vo-client glideinwms-minimal-condor glideinwms-userschedd \
        glideinwms-usercollector glideinwms-vofrontend-core \
        glideinwms-vofrontend-httpd httpd globus-proxy-utils;

# Install other utilities
RUN yum -y install \
    http://ssirepo04.fnal.gov/repos/sl-fermicontexts-el7-x86_64/fermilab-util_kx509-3.1-1.el7.noarch.rpm \
    krb5-workstation

# Install decisionengine
RUN curl http://ssi-rpm.fnal.gov/hep/ssi-hepcloud.repo > /etc/yum.repos.d/ssi-hepcloud.repo; \
    curl http://ssi-rpm.fnal.gov/hep/ssi-hepcloud-dev.repo > /etc/yum.repos.d/ssi-hepcloud-dev.repo; \
    yum -y install --enablerepo=ssi-hepcloud-dev \
        decisionengine \
        decisionengine_modules

ENTRYPOINT ["/bin/bash"]
