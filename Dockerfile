FROM docker.io/centos:8.3.2011

WORKDIR /root

RUN rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
RUN yum install -y dnf-plugins-core epel-release
RUN yum config-manager --set-enabled powertools

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

RUN yum install -y \
        python3 python3-pip python3-devel python3-pybind11 cmake make libuuid-devel json-c-devel gcc clang gcc-c++ hwloc-devel tbb-devel rpm-build rpmdevtools git

RUN dnf install -y libedit-devel
RUN dnf install -y libudev-devel
RUN dnf install -y libcap-devel
RUN python3 -m pip install setuptools python-pkcs11 pyyaml jsonschema wheel

WORKDIR /root
RUN git clone https://github.com/OPAE/opae-sdk.git /root/opae-sdk

ARG COMMIT_ID

WORKDIR /root/opae-sdk
RUN git checkout $COMMIT_ID

RUN yum upgrade -y libarchive

WORKDIR /root/opae-sdk/build
RUN sed -i 's/--use-local-refs//g' /root/opae-sdk/opae-libs/cmake/modules/OFS.cmake
RUN cmake .. --warn-uninitialized -Wno-dev \
             -DCMAKE_INSTALL_PREFIX=/opae \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_CXX_STANDARD=11 \
             -DSPDLOG_BUILD_EXAMPLE=ON \
             -DSPDLOG_BUILD_EXAMPLE_HO=ON \
             -DSPDLOG_BUILD_WARNINGS=ON \
             -DSPDLOG_BUILD_BENCH=OFF \
             -DSPDLOG_BUILD_TESTS=ON \
             -DCOMPILER_SUPPORTS_CXX14=no \
             -DSPDLOG_BUILD_TESTS_HO=OFF \
             -DSPDLOG_SANITIZE_ADDRESS=On && \
    make VERBOSE=1 install -j4

RUN cd /root/opae-sdk/python/opae.admin && python3 setup.py install --single-version-externally-managed --root=/opae
RUN cd /root/opae-sdk/python/pacsign && python3 setup.py install --single-version-externally-managed --root=/opae
RUN cd /root/opae-sdk/tools/extra/fpgadiag && python3 setup.py install --single-version-externally-managed --root=/opae

FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN microdnf install -y python3 python3-pip pciutils rsync kmod net-tools ethtool

COPY --from=0 /opae/bin/* /bin/
COPY --from=0 /opae/lib64/* /usr/lib64/
COPY --from=0 /opae/usr/local /usr/local
