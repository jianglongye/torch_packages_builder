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
    if command -v dnf >/dev/null; then
      dnf install -y mesa-libGL-devel mesa-libEGL-devel libglvnd-devel
    else
      sudo apt-get update
      sudo apt-get install -y --no-install-recommends libegl1-mesa-dev libgles2-mesa-dev libglvnd-dev
    fi
  fi
  # Rename *.cpp companions of same-named *.cu to avoid object-file collisions under build_ext.
  mv nvdiffrast/common/cudaraster/impl/RasterImpl.cpp nvdiffrast/common/cudaraster/impl/RasterImplHost.cpp
  mv nvdiffrast/common/texture.cpp nvdiffrast/common/textureHost.cpp
  patch -p0 < "$SCRIPT_DIR"/package_specific/nvdiffrast_precompile.patch
fi

if [[ $REPO == "facebookresearch/sam2" ]]; then
  # Force the upstream BuildExtensionIgnoreErrors shim to re-raise compile
  # errors instead of silently shipping a wheel without sam2/_C.so.
  echo "SAM2_BUILD_ALLOW_ERRORS=0" >> "$GITHUB_ENV"
fi

if [[ $REPO == "XR-Robotics/XRoboToolkit-PC-Service-Pybind" ]]; then
  # Stage the native PXREARobotSDK into ./lib + ./include so the upstream
  # CMakeLists picks it up. Mirrors scripts/devices/pico/install_sdk.sh's
  # ensure_native_lib() in retargetingkit-internal.
  SDK_REPO="https://github.com/XR-Robotics/XRoboToolkit-PC-Service.git"
  git clone --depth 1 "$SDK_REPO" tmp/sdk
  SRC="tmp/sdk/RoboticsService"
  mkdir -p lib include

  if [[ $OS == "Linux" ]]; then
    (cd "$SRC/PXREARobotSDK" && bash build.sh)
    cp "$SRC/PXREARobotSDK/PXREARobotSDK.h"            include/
    cp -r "$SRC/PXREARobotSDK/nlohmann"                include/
    cp "$SRC/PXREARobotSDK/build/libPXREARobotSDK.so"  lib/
    # Make the .so resolvable to the linker during `pip wheel` and to
    # auditwheel during the repair step.
    echo "$PWD/lib" > /etc/ld.so.conf.d/pxrearobot.conf
    ldconfig
  elif [[ $OS == "Windows" ]]; then
    cp "$SRC/PXREARobotSDK/PXREARobotSDK.h"   include/
    cp -r "$SRC/PXREARobotSDK/nlohmann"       include/
    cp "$SRC/SDK/win/64/PXREARobotSDK.dll"    lib/
    cp "$SRC/SDK/win/64/PXREARobotSDK.lib"    lib/
  fi

  # The upstream setup.py invokes cmake directly (not via pip's build-isolation
  # PEP 517), so the pybind11 cmake config from the host pip install is what
  # find_package() needs. Export the path.
  PYBIND11_CMAKE_DIR=$(python -m pybind11 --cmakedir)
  echo "CMAKE_PREFIX_PATH=$PYBIND11_CMAKE_DIR" >> "$GITHUB_ENV"
fi

if [[ $REPO == "jianglongye/torch_packages_builder" && ${REPO_SUBDIR:-} == "packages/manus_sdk_runtime" ]]; then
  PKG_LIB_DIR="packages/manus_sdk_runtime/src/manus_sdk_runtime/lib"
  if [[ $OS == "Linux" ]]; then
    mkdir -p "$PKG_LIB_DIR/linux"
    curl -L "${MANUS_SDK_LINUX_URL:?Set MANUS_SDK_LINUX_URL secret}" -o "$PKG_LIB_DIR/linux/libManusSDK_Integrated.so"
  elif [[ $OS == "Windows" ]]; then
    mkdir -p "$PKG_LIB_DIR/windows"
    curl -L "${MANUS_SDK_WINDOWS_URL:?Set MANUS_SDK_WINDOWS_URL secret}" -o "$PKG_LIB_DIR/windows/ManusSDK.dll"
  else
    echo "manus-sdk-runtime only supports Linux and Windows wheels" >&2
    exit 1
  fi
fi
