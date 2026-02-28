#!/usr/bin/env bash

set -e

pushd /tmp/llvm-project;

echo "Resource dir: $($SYSROOT/usr/bin/clang --print-resource-dir)"

IFS=';' read -ra TRIPLES_ARRAY <<< "$BUILD_TRIPLES"
IFS=';' read -ra MARCHS_ARRAY <<< "$BUILD_MARCHS"

echo "SYSROOT is $SYSROOT"

for triple in "${!TRIPLES_ARRAY[@]}"; do
    TRIPLE=${TRIPLES_ARRAY[$triple]}
    MARCH=${MARCHS_ARRAY[$triple]}

    echo "=================================="
    echo "Building triple $TRIPLE $MARCH"
    echo "=================================="

    COMPILER_FLAGS="--target=$TRIPLE $MARCH $COMMON_COMPILE_FLAGS"

    cmake   \
        -G Ninja \
        -B build-libcxx-runtimes-$TRIPLE            \
        -DCMAKE_BUILD_TYPE=Release                  \
        -DCMAKE_SYSROOT=$SYSROOT                    \
        -DCMAKE_C_COMPILER=$SYSROOT/usr/bin/clang       \
        -DCMAKE_CXX_COMPILER=$SYSROOT/usr/bin/clang++   \
        -DCMAKE_C_FLAGS="$COMPILER_FLAGS"           \
        -DCMAKE_CXX_FLAGS="$COMPILER_FLAGS"         \
        -DCMAKE_C_COMPILER_TARGET=$TRIPLE           \
        -DCMAKE_CXX_COMPILER_TARGET=$TRIPLE         \
        -DCMAKE_ASM_COMPILER_TARGET=$TRIPLE         \
        -DCMAKE_C_COMPILER_WORKS=TRUE               \
        -DCMAKE_CXX_COMPILER_WORKS=TRUE             \
        -DCMAKE_INSTALL_PREFIX="$SYSROOT/usr"       \
        -DLIBCXX_INSTALL_LIBRARY_DIR=lib/$TRIPLE    \
        -DLIBCXXABI_INSTALL_LIBRARY_DIR=lib/$TRIPLE \
        -DLIBUNWIND_INSTALL_LIBRARY_DIR=lib/$TRIPLE \
        -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
        -DLLVM_RUNTIME_TARGETS=$TRIPLE              \
        -DLLVM_RUNTIME_TRIPLE=$TRIPLE               \
        -DLLVM_HOST_TRIPLE=$TRIPLE                  \
        -DLLVM_TARGET_TRIPLE=$TRIPLE                \
        -DLLVM_DEFAULT_TARGET_TRIPLE=$TRIPLE        \
        -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON     \
        -DLIBCXX_CXX_ABI=libcxxabi                  \
        -DLIBCXX_HAS_MUSL_LIBC=ON                   \
        -DLIBCXX_INCLUDE_BENCHMARKS=OFF             \
        -DLIBCXX_INCLUDE_TESTS=OFF                  \
        -DLIBCXX_ENABLE_SHARED=ON                   \
        -DLIBCXXABI_USE_LLVM_UNWINDER=ON            \
        -DLIBCXXABI_USE_COMPILER_RT=ON              \
        -DLIBCXXABI_ENABLE_SHARED=ON                \
        -DLIBUNWIND_INSTALL_LIBRARY_DIR=lib/$TRIPLE \
        -DLIBUNWIND_USE_COMPILER_RT=ON              \
        -DCMAKE_LINKER=lld                          \
        -S runtimes

        # -DCXX_SUPPORTS_FNO_EXCEPTIONS_FLAG=ON    \
        # -DCXX_SUPPORTS_FUNWIND_TABLES_FLAG=ON    \

    cmake --build build-libcxx-runtimes-$TRIPLE --parallel;
    cmake --install build-libcxx-runtimes-$TRIPLE;
done
popd


echo "Done"
