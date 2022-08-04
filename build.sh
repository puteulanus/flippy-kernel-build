# 清理产物
rm -rf /tmp/{output,boot,modules,armbianboot}
mkdir /tmp/{output,boot,modules}
# 启动构建
cd /root/build
./compile.sh BOARD=station-p2 BRANCH=current RELEASE=bullseye BUILD_MINIMAL=yes \
    BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no COMPRESS_OUTPUTIMAGE=sha,gpg,img \
    SKIP_BOOTSPLASH=yes AUFS=no EXTRAWIFI=no BUILD_KSRC=no KERNEL_KEEP_CONFIG=no
# 整理产物
cp /tmp/armbianboot/{uInitrd-*,initrd.img-*} /tmp/boot
cd /tmp/boot
filename=$(ls uInitrd-*)
tar zcvf boot-${filename:8}.tar.gz *
cp boot-${filename:8}.tar.gz /tmp/output
cd /tmp/modules/lib/modules
tar zcvf modules-${filename:8}.tar.gz *
cp modules-${filename:8}.tar.gz /tmp/output
cd /tmp/output
tar zcvf flippy-kernel.tar.gz *
cp flippy-kernel.tar.gz /notebooks
