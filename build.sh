#!/bin/bash
set -e

TOOLCHAIN_PATH=$HOME/proton-clang/proton-clang-20210522/bin
echo "TOOLCHAIN_PATH: [$TOOLCHAIN_PATH]"
export PATH="$TOOLCHAIN_PATH:$PATH"
export CCACHE_DIR="$HOME/.cache/ccache_mikernel" 
export CC="ccache gcc"
export CXX="ccache g++"
export PATH="/usr/lib/ccache:$PATH"
echo "CCACHE_DIR: [$CCACHE_DIR]"


MAKE_ARGS="AS=as ARCH=arm64 SUBARCH=arm64 O=out CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- CLANG_TRIPLE=aarch64-linux-gnu-"

echo "[clang --version]:"
clang --version

make $MAKE_ARGS elish_user_defconfig

make $MAKE_ARGS -j$(nproc)

sleep 2
rm -rf out/repack; 
mkdir out/repack; sleep 2
echo "[ROM]: repack rom file."
unzip release.zip -d out/repack
cp out/arch/arm64/boot/Image out/repack/Image
cd out/repack; zip -r kernel.zip *; cd ../../
md5=$(md5sum out/repack/kernel.zip | cut -c1-8)
mv out/repack/kernel.zip kernel_elish_$(date +%Y%m%d)_anykernel3_$md5.zip
