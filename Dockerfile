FROM quay.io/puteulanus/flippy-kernel-build:cache as builder

ADD kernel.config /root/kernel.config

RUN cd /root && git clone https://github.com/armbian/build && cd build && \
    # 修改内核源码为 Flippy 源码库
    sed -i 's#git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git#https://github.com/puteulanus/linux-5.18.y#' lib/configuration.sh && \
    mkdir userpatches && \
    echo 'KERNELBRANCH="branch:main"' > userpatches/lib.config && \
    rm -f patch/kernel/station-p2-current/*.patch && \
    # 插入 hook 导出 boot 和 modules
    mkdir /tmp/{boot,modules}
    sed -i '/Creating packages/amake ARCH=arm64 INSTALL_PATH=/tmp/boot install' lib/compilation.sh
    sed -i '/Creating packages/amake ARCH=arm64 INSTALL_MOD_PATH=/tmp/modules modules_install' lib/compilation.sh
    sed -i 's/LOCALVERSION="-${LINUXFAMILY}"/LOCALVERSION=""/' lib/compilation.sh
    sed -i 's/LOCALVERSION="-$LINUXFAMILY"/LOCALVERSION=""/' lib/compilation.sh
    sed -i "/'PRE_INSTALL_KERNEL_DEBS'/iCHOSEN_KERNEL='linux-image-current'" lib/distributions.sh
    # 插入 hook 导出 uInitrd
    sed -i '/post_debootstrap_tweaks/acp -r $SDCARD/boot /tmp/armbianboot' lib/debootstrap.sh
    sed -i '/post_debootstrap_tweaks/aupdate_initramfs $SDCARD' lib/debootstrap.sh
    # 使用 Flippy 内核配置
    wget -O userpatches/linux-media-current.config 'https://raw.githubusercontent.com/unifreq/arm64-kernel-configs/main/config-5.18.14-flippy-75%2B'
    cat /root/kernel.config >> userpatches/linux-media-current.config
    # 启动构建
    ./compile.sh BOARD=station-p2 BRANCH=current RELEASE=bullseye BUILD_MINIMAL=yes \
    BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no COMPRESS_OUTPUTIMAGE=sha,gpg,img \
    SKIP_BOOTSPLASH=yes AUFS=no EXTRAWIFI=no BUILD_KSRC=no KERNEL_KEEP_CONFIG=no
    # 整理产物
    mkdir /root/output && \
    cp /tmp/armbianboot/{uInitrd-*,initrd.img-*} /tmp/boot && \
    cd /tmp/boot && \
    filename=$(ls uInitrd-*) && \
    tar zcvf boot-${filename:8}.tar.gz * && \
    cp boot-${filename:8}.tar.gz /root/output
    cd /tmp/modules/lib/modules && \
    tar zcvf modules-${filename:8}.tar.gz *
    cp modules-${filename:8}.tar.gz /root/output

FROM alpine as output
COPY --from=builder /root/output /root/
