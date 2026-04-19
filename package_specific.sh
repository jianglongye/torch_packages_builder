#! /bin/bash

set -eu -o pipefail

SCRIPT_DIR=${BASH_SOURCE%/*}

if [[ $REPO == "facebookresearch/pytorch3d" ]]; then
  if [[ $COMPUTE_PLATFORM == "cu118" ]] && [[ $OS == "Windows" ]]; then
    CUB_VERSION="1.17.2"
    mkdir cub
    curl -L https://github.com/NVIDIA/cub/archive/${CUB_VERSION}.tar.gz | tar -xzf - --strip-components=1 --directory cub
    echo "CUB_HOME=$PWD/cub" >> "$GITHUB_ENV"
  fi
fi

if [[ $REPO == "NVlabs/nvdiffrast" ]]; then
  if [[ $OS == "Linux" ]]; then
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends libegl1-mesa-dev libgles2-mesa-dev libglvnd-dev
  fi
  # Rename *.cpp companions of same-named *.cu to avoid object-file collisions under build_ext.
  mv nvdiffrast/common/cudaraster/impl/RasterImpl.cpp nvdiffrast/common/cudaraster/impl/RasterImplHost.cpp
  mv nvdiffrast/common/texture.cpp nvdiffrast/common/textureHost.cpp
  patch -p0 < "$SCRIPT_DIR"/package_specific/nvdiffrast_precompile.patch
fi
