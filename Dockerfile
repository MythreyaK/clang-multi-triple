FROM fedora:43

RUN dnf install -y      \
        z3              \
        z3-devel        \
        z3-libs         \
        git             \
        lld             \
        wget            \
        swig            \
        file            \
        cmake           \
        llvm            \
        clang           \
        rsync           \
        which           \
        binutil*        \
        libcxx*         \
        libcxx-devel*   \
        llvm-libunwind* \
        llvm-libunwind-devel*   \
        libpfm          \
        libpfm-devel    \
        diffutils       \
        python3-pip     \
        ninja-build     \
        python-devel    \
        glibc-headers   \
        inotify-tools   \
        glibc-headers   \
        libedit-devel   \
        libxml2-devel   \
        ncurses-devel   \
        jemalloc        \
        jemalloc-devel  \
        valgrind-devel  \
        libffi-devel    \
    && pip3 install     \
        pyyaml          \
        pygments        \
        swig            \
    && echo "done"

WORKDIR /tmp

ARG MUSL_VER=1.2.5
ARG LINUX_VER=6.18.5

RUN echo "Downloading deps"         \
    && wget -qO- "https://musl.libc.org/releases/musl-${MUSL_VER}.tar.gz" | tar xz \
    && mv musl-${MUSL_VER} musl     \
    && wget -qO- "https://www.kernel.org/pub/linux/kernel/v6.x/linux-${LINUX_VER}.tar.xz" | tar xJ \
    && mv linux-${LINUX_VER} linux  \
    && git clone --depth=1 https://github.com/llvm/llvm-project.git llvm-project \
    && echo "Done"

ARG SYSROOT=/sysroot
ARG INSTALL_PATH=/opt

WORKDIR ${SYSROOT}

RUN echo "Setting up sysroot"   \
    && pushd ${SYSROOT}         \
    && mkdir -pv usr/{include,lib,lib64,bin,sbin} \
    && ln -sfv usr/bin      bin     \
    && ln -sfv usr/sbin     sbin    \
    && ln -sfv usr/lib      lib     \
    && ln -sfv usr/lib64    lib64   \
    && popd                         \
    && echo "Done"

COPY build-llvm.sh /tmp/scripts/
RUN /tmp/scripts/build-llvm.sh

RUN dnf install nano tree -y

COPY install-linux-headers.sh /tmp/scripts/
RUN /tmp/scripts/install-linux-headers.sh

ARG BUILD_TRIPLES="x86_64-pc-linux-musl;i386-pc-linux-musl"
ARG BUILD_MARCHS="-m64;-m32"
ARG BUILD_LIB_SUFFIX=";64"

COPY install-musl-headers.sh /tmp/scripts/
RUN /tmp/scripts/install-musl-headers.sh

COPY common.cfg x86_64-pc-linux-musl.cfg i386-pc-linux-musl.cfg ${SYSROOT}/usr/bin/

COPY build-compiler_rt.sh /tmp/scripts/
RUN /tmp/scripts/build-compiler_rt.sh

COPY build-musl.sh /tmp/scripts/
RUN /tmp/scripts/build-musl.sh

COPY build-libcxx.sh /tmp/scripts/
RUN /tmp/scripts/build-libcxx.sh

RUN git clone -b newlib-4.6.0 --depth=1 https://sourceware.org/git/newlib-cygwin.git /tmp/newlib

# baremetal
ARG BUILD_TRIPLES="x86_64-unknown-none-elf;i386-unknown-none-elf"
ARG BUILD_MARCHS="-m64;-m32"
ARG BUILD_LIB_SUFFIX=";64"

COPY build-newlib.sh /tmp/scripts
RUN /tmp/scripts/build-newlib.sh

COPY x86_64-unknown-none-elf.cfg i386-unknown-none-elf.cfg ${SYSROOT}/usr/bin/
COPY build-compiler_rt-bm.sh /tmp/scripts
RUN /tmp/scripts/build-compiler_rt-bm.sh

COPY build-libcxx-bm.sh /tmp/scripts
RUN /tmp/scripts/build-libcxx-bm.sh
