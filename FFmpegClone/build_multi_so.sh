#!/bin/bash
NDK=/Users/niuzilin/Library/Android/ndk/android-ndk-r14b
ADDI_CFLAGS="-fPIE -pie"
ADDI_LDFLAGS="-fPIE -pie"

configure()
{
    CPU=$1
    PREFIX=$(pwd)/android_multi_lib/$CPU
    x264=$(pwd)/x264/android_lib_so/$CPU
    HOST=""
    CROSS_PREFIX=""
    SYSROOT=""
    ARCH=""
    if [ "$CPU" == "armeabi-v7a" ]
    then
        ARCH="arm"
        HOST=arm-linux
        SYSROOT=$NDK/platforms/android-21/arch-arm/
        CROSS_PREFIX=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
    else
        ARCH="aarch64"
        HOST=aarch64-linux
        SYSROOT=$NDK/platforms/android-21/arch-arm64/
        CROSS_PREFIX=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin/aarch64-linux-android-
    fi
    ./configure \
    --prefix=$PREFIX \
    --disable-encoders \
    --disable-decoders \
    --disable-avdevice \
    --disable-static \
    --disable-doc \
    --disable-ffplay \
    --enable-network \
    --disable-doc \
    --disable-symver \
    --enable-neon \
    --enable-shared \
    --enable-libx264 \
    --enable-gpl \
    --enable-pic \
    --enable-jni \
    --enable-pthreads \
    --enable-mediacodec \
    --enable-encoder=aac \
    --enable-encoder=pcm_alaw \
    --enable-encoder=gif \
    --enable-encoder=libopenjpeg \
    --enable-encoder=libmp3lame \
    --enable-encoder=libwavpack \
    --enable-encoder=libx264 \
    --enable-encoder=mpeg4 \
    --enable-encoder=pcm_s16le \
    --enable-encoder=png \
    --enable-encoder=srt \
    --enable-encoder=subrip \
    --enable-encoder=yuv4 \
    --enable-encoder=text \
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=pcm_alaw \
    --enable-decoder=libopenjpeg \
    --enable-decoder=mp3 \
    --enable-decoder=mpeg4_mediacodec \
    --enable-decoder=pcm_s16le \
    --enable-decoder=flac \
    --enable-decoder=flv \
    --enable-decoder=gif \
    --enable-decoder=png \
    --enable-decoder=srt \
    --enable-decoder=xsub \
    --enable-decoder=yuv4 \
    --enable-decoder=vp8_mediacodec \
    --enable-decoder=h264_mediacodec \
    --enable-decoder=hevc_mediacodec \
    --enable-hwaccel=h264_mediacodec \
    --enable-hwaccel=mpeg4_mediacodec \
    --enable-ffmpeg \
    --enable-bsf=aac_adtstoasc \
    --enable-bsf=h264_mp4toannexb \
    --enable-bsf=hevc_mp4toannexb \
    --enable-bsf=mpeg4_unpack_bframes \
    --enable-cross-compile \
    --cross-prefix=$CROSS_PREFIX \
    --target-os=android \
    --arch=$ARCH \
    --sysroot=$SYSROOT \
    --extra-cflags="-I$x264/include $ADDI_CFLAGS" \
    --extra-ldflags="-L$x264/lib"
}

build()
{
    make clean
    cpu=$1
    echo "build $cpu"
    
    configure $cpu
    make -j4
    make install
}

build arm64-v8a
build armeabi-v7a