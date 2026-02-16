#!/usr/bin/env bash

set -e

pushd /tmp/musl;

IFS=';' read -ra TRIPLES_ARRAY <<< "$BUILD_TRIPLES";
IFS=';' read -ra MARCHS_ARRAY <<< "$BUILD_MARCHS";

for triple in "${!TRIPLES_ARRAY[@]}"; do
    export TRIPLE=${TRIPLES_ARRAY[$triple]}
    export MARCH=${MARCHS_ARRAY[$triple]}

    echo "=================================="
    echo "Building triple $TRIPLE $MARCH"
    echo "=================================="

    mkdir -p build-$TRIPLE
    pushd build-$TRIPLE

    arch_flag=""

    if [[ $arch == "x86_64" ]]; then libdir_suffix="64"; arch_flag="-m64"; fi
    if [[ $arch == "i386" ]];   then libdir_suffix="";   arch_flag="-m32"; fi

    ../configure                    \
        --prefix=/usr               \
        --target=$TRIPLE            \
        --libdir=$SYSROOT/usr/lib/$TRIPLE       \
        --syslibdir=$SYSROOT/usr/lib/$TRIPLE    \
        --includedir=$SYSROOT/usr/include/$TRIPLE       \
        --libdir=$SYSROOT/usr/lib/$TRIPLE       \
        --syslibdir=$SYSROOT/usr/lib/$TRIPLE    \
        CC=$SYSROOT/usr/bin/clang               \
        AR=$SYSROOT/usr/bin/llvm-ar             \
        RANLIB=$SYSROOT/usr/bin/llvm-ranlib     \
        CFLAGS="--sysroot=$SYSROOT $MARCH -fuse-ld=lld -fstack-protector-strong -fstack-clash-protection -fno-omit-frame-pointer" \
        LDFLAGS="--sysroot=$SYSROOT $MARCH -fuse-ld=lld" \
        LIBCC=$($SYSROOT/usr/bin/clang --print-resource-dir)/lib/$TRIPLE/libclang_rt.builtins.a
    make -j
    make install

    popd
done
popd
