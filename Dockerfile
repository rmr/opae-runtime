FROM docker.io/rockylinux:8.5
ARG OPAE_VERSION

WORKDIR /root

RUN rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
RUN yum install -y dnf-plugins-core epel-release
RUN yum config-manager --set-enabled powertools

RUN rpm -i https://github.com/OPAE/opae-sdk/releases/download/$OPAE_VERSION/opae-$OPAE_VERSION.fc34.src.rpm
RUN curl -sL https://github.com/OPAE/opae-sdk/releases/download/$OPAE_VERSION/opae.spec -o /root/rpmbuild/SPECS/opae.spec

WORKDIR /root/rpmbuild/SPECS

RUN dnf builddep -y opae.spec
RUN dnf install -y rpm-build rpmdevtools

RUN spectool -g -R opae.spec
RUN rpmbuild -ba opae.spec

FROM registry.access.redhat.com/ubi8/ubi-minimal

ARG OPAE_VERSION

RUN microdnf install -y uuid \
                        python3 \
                        python3-pip \
                        pciutils \
                        rsync \
                        kmod \
                        net-tools \
                        ethtool && \
    microdnf update

COPY --from=0 /root/rpmbuild/RPMS/x86_64/opae-$OPAE_VERSION.el8.x86_64.rpm /root/opae.rpm
RUN rpm -i --force --nodeps /root/opae.rpm
