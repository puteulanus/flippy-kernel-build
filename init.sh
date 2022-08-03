#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq locales

cd /root && git clone https://github.com/armbian/build
cd build
# 修改内核源码为 Flippy 源码库
sed -i 's#git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git#https://github.com/puteulanus/linux-5.18.y#' lib/configuration.sh
mkdir userpatches
echo 'KERNELBRANCH="branch:main"' > userpatches/lib.config
rm -f patch/kernel/station-p2-current/*.patch
# 插入 hook 导出 boot 和 modules
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
cat /notebooks/kernel.config >> userpatches/linux-media-current.config
# 拷贝 ccache 缓存
rm -rf /root/.ccache
cp -r /notebooks/.ccache /root/
