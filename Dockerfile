FROM ubuntu:22.04

# 设置时区，避免交互
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    flex \
    bison \
    g++ \
    gawk \
    gcc \
    git \
    libc-dev \
    libncurses5-dev \
    libssl-dev \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-yaml \
    rsync \
    subversion \
    unzip \
    wget \
    file \
    cmake \
    ninja-build \
    sudo \
    xz-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN bash -c 'bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh)'

# 创建非 root 用户（可选）
RUN useradd -m -s /bin/bash builder && echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

# RUN chown -R builder:builder /home/builder

# 切换到非 root 用户
USER builder
WORKDIR /home/builder

# 克隆 ImmortalWrt 源码
RUN git clone https://github.com/immortalwrt/immortalwrt.git

# RUN sudo chown -R builder:builder /home/builder/immortalwrt/bin

# 进入源码目录
WORKDIR /home/builder/immortalwrt

RUN git switch --track origin/openwrt-24.10

# 更新 feeds（可以根据需要修改）
RUN ./scripts/feeds update -a && ./scripts/feeds install -a

# 预设编译配置（可选）
COPY config.buildinfo .config
RUN sudo chown -R builder:builder /home/builder/immortalwrt/.config

# 结束
CMD ["/bin/bash"]
