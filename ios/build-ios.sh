#!/bin/bash


WORKSPACE_CURRENT=$(pwd)
ARCH="arm64"

# 检查操作系统类型
OS=$(uname)
if [ "$OS" == "Darwin"  ];
then
    echo "Is MacOS build 。。。。"
else
    echo "Unsupported operating system: $OS"
    exit 1
fi
cd ../ || exit
mkdir -p build && cd build || exit
WORKSPACE_CURRENT=$(pwd)
echo "WORKSPACE_CURRENT = ${WORKSPACE_CURRENT}"
function build_openh264() {
    local third_party_path="${WORKSPACE_CURRENT}../src/third_party"
    local OPENH264_PATH="${third_party_path}/openh264"
    cd "${OPENH264_PATH}" || exit
    make OS=ios ARCH=${ARCH} clean
    make OS=ios ARCH=${ARCH}
    make OS=ios ARCH=${ARCH} install-static
}
function setting_pkg() {
    echo "pkgconfig=$(which pkgconfig)"
    echo "pkgconfig=$(whereis pkgconfig)"
    local third_party_path="${WORKSPACE_CURRENT}../src/third_party"
    local X264_PATH="${third_party_path}/x264/${ARCH}"
    local FDK_AAC_PATH="${third_party_path}/fdk-aac/${ARCH}"
    local OPUS_PATH="${third_party_path}/opus/${ARCH}"
    local OPENSSL_PATH="${third_party_path}/openssl/${ARCH}"
    local FFMPEG_PATH="${third_party_path}/ffmpeg/${ARCH}"

    # Concatenate paths step by step
    PKG_CONFIG_PATH="$X264_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$FDK_AAC_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$OPUS_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$OPENSSL_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$FFMPEG_PATH/lib/pkgconfig"

    # Export the final PKG_CONFIG_PATH
    export PKG_CONFIG_PATH
    echo "PKG_CONFIG_PATH = ${PKG_CONFIG_PATH}"
}
setting_pkg
cmake .. -G Xcode \
        -DCMAKE_TOOLCHAIN_FILE=../cmake/ios.toolchain.cmake \
        -DOK_RTC_BUILD_AUDIO_BACKENDS=OFF \
        -DOK_RTC_USE_PIPEWIRE=OFF \
        -DPLATFORM=OS64 \
        -DENABLE_BITCODE=FALSE \
        -DCMAKE_INSTALL_PREFIX="$(pwd)/install/${ARCH}"
cmake --build . --config Release
# make install