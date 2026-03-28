FROM ubuntu:24.04

# 1. 自动换源 (中国科学技术大学镜像源)
# Ubuntu 24.04 使用 DEB822 格式
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources

# 2. 安装 OpenWrt 编译所需的完整依赖 (针对 Ubuntu 24 优化)
# 移除了过时的包，添加了必需的 python3 环境和工具
RUN apt-get update && apt-get install -y \
    bash build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses-dev libssl-dev rsync unzip zlib1g-dev \
    file wget python3 python3-pip python3-setuptools python3-pyelftools \
    libpcre3-dev swig libelf-dev quilt ecj fastjar \
    java-propose-classpath qemu-utils time sudo micro vim ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. 创建非 root 用户 (满足 OpenWrt 编译要求)
# 用户名: builder, 密码: 空, 且拥有 sudo 权限
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 4. 设置工作目录和用户权限
WORKDIR /home/builder/openwrt
RUN chown builder:builder /home/builder/openwrt

# 5. 切换到新用户
USER builder

# 设置默认启动命令，保持容器运行
CMD ["/bin/bash"]
