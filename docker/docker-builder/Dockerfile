FROM debian:stretch

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y install apt-utils

RUN DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y install \
    binfmt-support    \
    bsdtar            \
    build-essential   \
    ca-certificates   \
    curl              \
    dosfstools        \
    file              \
    git               \
    grep              \
    libcap2-bin       \
    lzop              \
    multistrap        \
    parted            \
    pxz               \
    qemu              \
    qemu-user-static  \
    rsync             \
    u-boot-tools      \
    udev              \
    wget              \
    xxd               \
    xz-utils          \
    zerofree          \
    zip

# Cleanup APT Leftovers
# (Docker automatically runs apt-clean)
#
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /be
WORKDIR /be

VOLUME /be/plugins
VOLUME /be/functions
VOLUME /be/package-cache
VOLUME /be/images
VOLUME /be/clients

COPY builder-Makefile /be/Makefile

COPY rpi-img-builder /be/builder

COPY builder-apt.conf /be/builder/apt.conf

ARG APT_PROXY=
RUN sed -i "s|\${APT_PROXY}|${APT_PROXY}|g" /be/builder/apt.conf

CMD ["/bin/bash"]
