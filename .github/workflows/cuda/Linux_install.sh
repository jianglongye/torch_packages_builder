#! /bin/bash

CUDA_SHORT=${CUDA_VERSION:2:2}-${CUDA_VERSION:4:1}
if command -v dnf >/dev/null; then
  # nvcc host-compiler ceiling: 11.x → gcc 11, 12.0-12.3 → gcc 12,
  # 12.4-12.8 → gcc 13, 12.9+/13.x → gcc 14.
  case "$CUDA_VERSION" in
    cu118) GCC_TOOLSET=11 ;;
    cu120|cu121|cu122|cu123) GCC_TOOLSET=12 ;;
    cu124|cu125|cu126|cu127|cu128) GCC_TOOLSET=13 ;;
    *) GCC_TOOLSET=14 ;;
  esac
  curl -L -o /etc/yum.repos.d/cuda.repo \
    https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
  dnf install -y cuda-nvcc-$CUDA_SHORT cuda-libraries-devel-$CUDA_SHORT \
    gcc-toolset-${GCC_TOOLSET}-gcc gcc-toolset-${GCC_TOOLSET}-gcc-c++
  echo "/opt/rh/gcc-toolset-${GCC_TOOLSET}/root/usr/bin" >> "$GITHUB_PATH"
else
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb -O cuda-keyring.deb
  sudo dpkg -i cuda-keyring.deb
  sudo apt update
  sudo apt install --no-install-recommends cuda-nvcc-$CUDA_SHORT cuda-libraries-dev-$CUDA_SHORT
fi
