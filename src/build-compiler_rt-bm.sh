#!/usr/bin/env bash

set -e

pushd /tmp/llvm-project

IFS=';' read -ra TRIPLES_ARRAY <<< "$BUILD_TRIPLES"
IFS=';' read -ra MARCHS_ARRAY <<< "$BUILD_MARCHS"

echo "SYSROOT is $SYSROOT"

for triple in "${!TRIPLES_ARRAY[@]}"; do
    TRIPLE=${TRIPLES_ARRAY[$triple]}
    MARCH=${MARCHS_ARRAY[$triple]}

    echo "=================================="
    echo "Building triple $TRIPLE $MARCH"
    echo "=================================="

    $SYSROOT/usr/bin/clang --print-resource-dir

    COMPILER_FLAGS="--target=$TRIPLE $MARCH $BM_TRIPLE_COMPILE_FLAGS -nostdlib"

    cmake \
        -G Ninja \
        -B build-compiler_rt-bm-$TRIPLE                 \
        -DCMAKE_SYSROOT=$SYSROOT                        \
        -DCMAKE_CXX_FLAGS="$COMPILER_FLAGS"             \
        -DCMAKE_C_FLAGS="$COMPILER_FLAGS"               \
        -DCMAKE_BUILD_TYPE=Release                      \
        -DCMAKE_C_COMPILER=$SYSROOT/usr/bin/clang       \
        -DCMAKE_CXX_COMPILER=$SYSROOT/usr/bin/clang++   \
        -DCMAKE_AR=$SYSROOT/usr/bin/llvm-ar             \
        -DCMAKE_RANLIB=$SYSROOT/usr/bin/llvm-ranlib     \
        -DCMAKE_NM=$SYSROOT/usr/bin/llvm-nm             \
        -DCMAKE_C_COMPILER_TARGET=$TRIPLE               \
        -DCMAKE_CXX_COMPILER_TARGET=$TRIPLE             \
        -DCMAKE_ASM_COMPILER_TARGET=$TRIPLE             \
        -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr"           \
        -DCOMPILER_RT_INSTALL_PATH=$($SYSROOT/usr/bin/clang --print-resource-dir)  \
        -DCOMPILER_RT_BUILD_CRT=ON                      \
        -DCOMPILER_RT_BUILD_BUILTINS=ON                 \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON            \
        -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF             \
        -DCOMPILER_RT_BUILD_SANITIZERS=OFF              \
        -DCOMPILER_RT_BUILD_LIBFUZZER=OFF               \
        -DCOMPILER_RT_BUILD_MEMPROF=OFF                 \
        -DCOMPILER_RT_BUILD_PROFILE=OFF                 \
        -DCOMPILER_RT_BUILD_XRAY=OFF                    \
        -DCOMPILER_RT_BUILD_ORC=OFF                     \
        -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=TRUE       \
        -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=FALSE      \
        -DLLVM_CMAKE_DIR=/tmp/llvm-project/build-llvm   \
        -DLLVM_USE_LINKER=lld                           \
        -DCOMPILER_RT_BAREMETAL_BUILD=ON                \
        -DCOMPILER_RT_OS_DIR=""                         \
        -S compiler-rt

    cmake --build build-compiler_rt-bm-$TRIPLE;
    cmake --install build-compiler_rt-bm-$TRIPLE;
done
popd
