#!/usr/bin/env bash

set -e

archs=("i386 x86_64")

function install_linux_headers() {
    pushd /tmp/linux

    echo "================================================="
    echo "Installing Linux $LINUX_VER headers: $PWD"
    echo "================================================="

    for arch in $archs; do

        linux_arch=$arch;

        if [[ $arch == "aarch64" ]]; then linux_arch=arm64; fi
        if [[ $arch == "riscv64" ]]; then linux_arch=riscv; fi

        # sorry lol
        cp -r /tmp/linux /tmp/linux-$arch

        pushd /tmp/linux-$arch
        LINUX_HEADER_INSTALL=$SYSROOT/usr/include/$arch-pc-linux-musl
        echo "Generating $arch: Installing to $LINUX_HEADER_INSTALL"

        make headers            INSTALL_HDR_PATH=$LINUX_HEADER_INSTALL -j
        make headers_install    INSTALL_HDR_PATH=$LINUX_HEADER_INSTALL -j

        # mkdir -p $SYSROOT/usr/include/$arch-pc-linux-musl
        # rsync -a --remove-source-files /tmp/linux-headers/$arch/include/asm/ $SYSROOT/usr/include/$arch-pc-linux-musl/asm/

        mv $LINUX_HEADER_INSTALL/include/*     $LINUX_HEADER_INSTALL/
        rmdir $LINUX_HEADER_INSTALL/include

        popd

    done;

    find $SYSROOT/usr/include/ -iname a.out.h -delete

    popd
}

install_linux_headers
