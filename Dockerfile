FROM quay.io/centos/centos:9

# Set the working directory in the container to /app
WORKDIR /app

# Update the package index
RUN dnf update -y

# compilers and deps
RUN dnf install -y \
    epel-release \
    gcc \
    gcc-c++ \
    libstdc++-devel \
    glibc-devel \
    zlib-devel \
    ncurses-devel

# Install Clang and Clang++
RUN dnf install -y \
    clang15 \
    llvm15-devel
#    llvm-toolset

RUN ln -s /usr/bin/clang-15 /usr/bin/clang
RUN ln -s /usr/bin/clang++-15 /usr/bin/clang++

# # Set environment variables
ENV CC=clang
ENV CXX=clang++
# # Verify the installation
RUN clang --version
RUN clang++ --version

# enable crb for install ninja-build
RUN dnf config-manager --enable crb
# tools
RUN dnf install -y \
    git \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    ninja-build \
    emacs-nox \
    parallel \
    which

# Install folly dependencies
# build fmt, because centos fmt version is too old
RUN dnf install -y \
    openssl-devel \
    openssl \
    gflags-devel \
    gtest-devel \
    glog-devel \
    boost-devel \
    boost-static \
    libdwarf-devel \
    libevent-devel \
    libsodium-devel \
    double-conversion-devel \
    fast_float-devel \
    lz4-devel \
    snappy-devel \
    libunwind-devel \
    xz \
    libzstd-devel \
    binutils-devel # for libiberty

# Install fizz dependencies
# already installed:
#   * libsodium
#   * libzstd-devel
# will be built:
#   * folly
#   * liboqs
RUN dnf install -y \
    zlib-devel


# Install fbthrift dependencies
# already installed:
#   * fmt
#   * googletest
#   * libsodium
#   * zstd
# will be built:
#   * wangle
#   * mvfst
#   * folly
#   * fizz
RUN dnf install -y \
    xxhash-devel \
    xxhash \
    bzip2-devel \
    libaio-devel \
    xz-devel


# Install llm predictor dependencies
RUN dnf install -y \
    python3.12 \
    python3.12-devel \
    python3.12-pip

RUN ln -sf /usr/bin/python3.12 /usr/bin/python3
RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/pip3.12 /usr/bin/pip

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustc --version


# Clone the fbthrift Git project
RUN git clone https://github.com/xli/fbthrift.git

# Change into the cloned repository
WORKDIR /app/fbthrift

# Install
RUN make env install jmtest


# make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

# Run bash when the container launches
CMD ["bash"]