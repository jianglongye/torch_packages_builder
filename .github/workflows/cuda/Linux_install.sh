#! /bin/bash

CUDA_SHORT=${CUDA_VERSION:2:2}-${CUDA_VERSION:4:1}
if command -v dnf >/dev/null; then
  curl -L -o /etc/yum.repos.d/cuda.repo \
    https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
  dnf install -y cuda-nvcc-$CUDA_SHORT cuda-libraries-devel-$CUDA_SHORT \
    gcc-toolset-13-gcc gcc-toolset-13-gcc-c++
  echo "/opt/rh/gcc-toolset-13/root/usr/bin" >> "$GITHUB_PATH"
else
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb -O cuda-keyring.deb
  sudo dpkg -i cuda-keyring.deb
  sudo apt update
  sudo apt install --no-install-recommends cuda-nvcc-$CUDA_SHORT cuda-libraries-dev-$CUDA_SHORT
fi
