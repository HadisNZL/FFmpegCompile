#!/bin/bash
make clean
NDK=/Users/niuzilin/Library/Android/ndk/android-ndk-r14b

configure()
{
    CPU=$1
    PREFIX=$(pwd)/android_lib_so/$CPU
    HOST=""
    CROSS_PREFIX=""
    SYSROOT=""
    if [ "$CPU" == "armeabi-v7a" ]
    then
        HOST=arm-linux
        SYSROOT=$NDK/platforms/android-21/arch-arm/
        CROSS_PREFIX=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
    else
        HOST=aarch64-linux
        SYSROOT=$NDK/platforms/android-21/arch-arm64/
        CROSS_PREFIX=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin/aarch64-linux-android-
    fi
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-pic \
    --enable-static \
    --enable-neon \
    --extra-cflags="-fPIE -pie" \
    --extra-ldflags="-fPIE -pie" \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT
}

build()
{
    make clean
    cpu=$1
    echo "build $cpu"

    configure $cpu
    #-j<CPU核心数>
    make -j4
    make install
}

build arm64-v8a
build armeabi-v7a