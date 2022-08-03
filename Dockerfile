FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git wget acl uuid-runtime systemd sudo locales
RUN git clone https://github.com/armbian/build && \
    cd build && \
    ./compile.sh BOARD=station-p2 BRANCH=current RELEASE=bullseye BUILD_MINIMAL=yes \
    BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no COMPRESS_OUTPUTIMAGE=sha,gpg,img \
    SKIP_BOOTSPLASH=yes AUFS=no EXTRAWIFI=no BUILD_KSRC=no KERNEL_KEEP_CONFIG=no
