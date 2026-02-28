#!/usr/bin/env bash

set -e

archs=("i386 x86_64")

function install_musl_headers() {
    pushd /tmp/musl

    for arch in $archs; do
        echo "================================================="
        echo "Installing musl headers: $arch" $PWD
        echo "================================================="

        make clean

        mkdir -p build-headers-$arch
        pushd build-headers-$arch

        echo "In dir $PWD"

        arch_flag=""

        if [[ $arch == "x86_64" ]]; then libdir_suffix="64"; arch_flag="-m64"; fi
        if [[ $arch == "i386" ]];   then libdir_suffix="";   arch_flag="-m32"; fi

        TRIPLE=$arch-pc-linux-musl

        ../configure                        \
            --prefix=$SYSROOT/usr           \
            --target=$TRIPLE                \
            --includedir=$SYSROOT/usr/include/$TRIPLE   \
            --libdir=lib$$SYSROOT/usr/lib/$TRIPLE   \
            --syslibdir=$SYSROOT/usr/lib/$TRIPLE    \
            CC=$SYSROOT/usr/bin/clang               \
            AR=$SYSROOT/usr/bin/llvm-ar             \
            RANLIB=$SYSROOT/usr/bin/llvm-ranlib     \
            CFLAGS="$arch_flag -fstack-protector-strong -fstack-clash-protection $COMMON_COMPILE_FLAGS"

        make install-headers

        popd
    done;
    popd

    echo "Done"
}

install_musl_headers
