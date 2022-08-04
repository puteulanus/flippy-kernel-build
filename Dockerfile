FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git wget acl uuid-runtime systemd sudo locales && apt-get upgrade -qq -y && \
    cd /root && \
    git clone https://github.com/armbian/build && \
    cd build && \
    sed -i 's#git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git#https://github.com/puteulanus/linux-5.18.y#' lib/configuration.sh && \
    rm -f patch/kernel/station-p2-current/*.patch && \
    mkdir userpatches && \
    echo 'KERNELBRANCH="branch:main"' > userpatches/lib.config && \
    ./compile.sh  BOARD=station-p2 BRANCH=current RELEASE=bullseye BUILD_MINIMAL=yes BUILD_DESKTOP=no KERNEL_ONLY=yes KERNEL_CONFIGURE=no \
    COMPRESS_OUTPUTIMAGE=sha,gpg,img SKIP_BOOTSPLASH=yes AUFS=no EXTRAWIFI=no BUILD_KSRC=no KERNEL_KEEP_CONFIG=no && \
    cd /root && \
    rm -rf build
