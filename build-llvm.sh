echo "Building LLVM"

pushd /tmp/llvm-project

cmake               \
    -G Ninja        \
    -B build-llvm   \
    -DCMAKE_C_COMPILER=/usr/bin/clang               \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++           \
    -DCMAKE_BUILD_TYPE=Release                      \
    -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr             \
    -DLLVM_ENABLE_PROJECTS="bolt;clang;clang-tools-extra;lld;lldb"              \
    -DLLVM_TARGETS_TO_BUILD="AArch64;AMDGPU;ARM;NVPTX;RISCV;WebAssembly;X86"    \
    -DLLVM_RUNTIME_TARGETS="x86_64-pc-linux-musl"   \
    -DLLVM_HOST_TRIPLE="x86_64-pc-linux-musl"       \
    -DLLVM_OPTIMIZED_TABLEGEN=ON                    \
    -DLLVM_LINK_LLVM_DYLIB=ON                       \
    -DLLVM_ENABLE_LIBCXX=ON                         \
    -DLLVM_ENABLE_RTTI=ON                           \
    -DLLVM_ENABLE_FFI=ON                            \
    -DLLVM_ENABLE_Z3_SOLVER=ON                      \
    -DLLVM_ENABLE_ZLIB=ON                           \
    -DLLVM_ENABLE_ZSTD=ON                           \
    -DLLVM_INSTALL_UTILS=ON                         \
    -DLLVM_BUILD_DOCS=OFF                           \
    -DLLVM_INCLUDE_EXAMPLES=OFF                     \
    -DLLVM_BUILD_EXAMPLES=OFF                       \
    -DLLVM_INCLUDE_TESTS=OFF                        \
    -DLLVM_BUILD_TESTS=OFF                          \
    -DLLVM_INCLUDE_BENCHMARKS=OFF                   \
    -DLLVM_BUILD_BENCHMARKS=OFF                     \
    -DLLVM_BUILD_LLVM_DYLIB=ON                      \
    -DLLVM_LINK_LLVM_DYLIB=ON                       \
    -DLLVM_ENABLE_LIBEDIT=ON                        \
    -DLLVM_BINUTILS_INCDIR=/usr/include             \
    -DLLVM_USE_LINKER=lld                           \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF                 \
    -DLIBCXX_USE_COMPILER_RT=ON                     \
    -DLIBCXX_INSTALL_MODULES=ON                     \
    -S llvm

cmake --build build-llvm   --parallel
cmake --install build-llvm

echo "Done"
