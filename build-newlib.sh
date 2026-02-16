#!/usr/bin/env bash

set -e

IFS=';' read -ra TRIPLES_ARRAY <<< "$BUILD_TRIPLES"
IFS=';' read -ra MARCHS_ARRAY <<< "$BUILD_MARCHS"

echo "SYSROOT is $SYSROOT"

pushd /tmp/newlib/newlib

for triple in "${!TRIPLES_ARRAY[@]}"; do
    TRIPLE=${TRIPLES_ARRAY[$triple]}
    MARCH=${MARCHS_ARRAY[$triple]}
    TRIPLE_GCC=$(echo $TRIPLE | sed 's|unknown-||g')

    echo "========================================================="
    echo "Building triple $TRIPLE $MARCH ($TRIPLE_GCC)"
    echo "========================================================="

    rm -f config.cache

    mkdir -p $PWD/build-$TRIPLE
    pushd $PWD/build-$TRIPLE

    # newlib installs to <prefix>/triple/{include,lib}
    # we need <prefix>/include/<triple> and <prefix>/lib/<triple>
    mkdir -p $SYSROOT/usr/include/$TRIPLE
    mkdir -p $SYSROOT/usr/lib/$TRIPLE

    INSTALL_ROOT=/tmp/newlib-install/$TRIPLE_GCC
    mkdir -p $INSTALL_ROOT

    ln -s $SYSROOT/usr/include/$TRIPLE  $INSTALL_ROOT/include
    ln -s $SYSROOT/usr/lib/$TRIPLE      $INSTALL_ROOT/lib

    ../configure \
        --prefix=/tmp/newlib-install            \
        --host=$TRIPLE_GCC                      \
        --target=$TRIPLE_GCC                    \
        --build=x86_64-redhat-linux             \
        --enable-newlib-io-pos-args             \
        --enable-newlib-io-c99-formats          \
        --enable-newlib-register-fini           \
        --enable-newlib-io-long-long            \
        --enable-newlib-io-long-double          \
        --enable-newlib-iconv-encodings=us_ascii,utf_8  \
        --enable-newlib-retargetable-locking    \
        --enable-newlib-use-gdtoa               \
        --enable-malloc-debugging               \
        --enable-newlib-iconv                   \
        --enable-newlib-multithread             \
        --disable-newlib-supplied-syscalls      \
        CC="$SYSROOT/usr/bin/clang"   \
        CXX="$SYSROOT/usr/bin/clang++" \
        AR="$SYSROOT/usr/bin/llvm-ar" \
        CFLAGS="--target=$TRIPLE $MARCH -g -Wno-everything -O2 -mno-mmx -mno-red-zone -ffreestanding" \
        CCASFLAGS="--target=$TRIPLE $MARCH -g -Wno-everything -O2 -mno-mmx -mno-red-zone -ffreestanding" \

    make -j
    make install -j
    popd;
done;

popd
