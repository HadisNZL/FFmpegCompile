make clean
cd compat
rm -rf strtod.d
rm -rf strtod.o
cd ../

set -e

archbit=32

if [ $archbit -eq 32 ];then
#32bit
ABI='armeabi-v7a'
CPU='arm'
API=21
ARCH='arm'
ANDROID='androideabi'
NATIVE_CPU='armv7-a'
OPTIMIZE_CFLAGS="-march=$NATIVE_CPU -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
else
#64bit
ABI='arm64-v8a'
CPU='aarch64'
API=21
ARCH='arm64'
ANDROID='android'
NATIVE_CPU='armv8-a'
OPTIMIZE_CFLAGS=""
fi

echo "build for $ABI,decoder and encoder support G711a"
export NDK=/Users/niuzilin/Library/Android/ndk/android-ndk-r14b
export PREBUILT=$NDK/toolchains/$CPU-linux-$ANDROID-4.9/prebuilt
export PLATFORM=$NDK/platforms/android-$API/arch-$ARCH
export TOOLCHAIN=$PREBUILT/darwin-x86_64
export PREFIX=./android_single_lib/$ABI
export ADDITIONAL_CONFIGURE_FLAG="--cpu=$NATIVE_CPU"

LAMEDIR=$PREFIX
export EXTRA_CFLAGS="-Os -fpic $OPTIMIZE_CFLAGS -I$LAMEDIR/include"
export EXTRA_LDFLAGS="-lc -lm -ldl -llog -lgcc -lz -L$LAMEDIR/lib"

x264=$(pwd)/x264/android_lib_so/$ABI
export EXTRA_CFLAGS_X264="-Os -fpic $OPTIMIZE_CFLAGS -I$x264/include"
export EXTRA_LDFLAGS_X264="-lc -lm -ldl -llog -lgcc -lz -L$x264/lib"

build_one(){
  ./configure --target-os=android --prefix=$PREFIX \
--enable-cross-compile \
--arch=$CPU \
--cc=$TOOLCHAIN/bin/$CPU-linux-$ANDROID-gcc \
--cross-prefix=$TOOLCHAIN/bin/$CPU-linux-$ANDROID- \
--sysroot=$PLATFORM \
--enable-neon \
--disable-hwaccels \
--enable-static \
--disable-shared \
--disable-runtime-cpudetect \
--disable-doc \
--disable-htmlpages \
--disable-manpages \
--disable-podpages \
--disable-txtpages \
--disable-asm \
--enable-small \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-debug \
--enable-gpl \
--disable-avdevice \
--disable-indevs \
--disable-outdevs \
--disable-avresample \
--extra-cflags="$EXTRA_CFLAGS" \
--extra-ldflags="$EXTRA_LDFLAGS" \
--extra-cflags="$EXTRA_CFLAGS_X264" \
--extra-ldflags="$EXTRA_LDFLAGS_X264" \
--enable-avcodec \
--enable-avformat \
--enable-avutil \
--enable-swresample \
--enable-swscale \
--enable-avfilter \
--enable-network \
--enable-libx264 \
--enable-bsfs \
--enable-postproc \
--enable-filters \
--enable-encoders \
--enable-encoder=libx264,mpeg4,aac,pcm_alaw \
--disable-decoders \
--enable-decoder=mjpeg,mpeg4,h264,flv,hevc,aac,aac_latm,vp8,vp9,mp3,pcm_alaw,\
h264_mediacodec,hevc_mediacodec,mpeg4_mediacodec,vp9_mediacodec \
--disable-muxers \
--enable-muxer=mp4,mov,mjpeg \
--disable-parsers \
--enable-parser=aac,aac_latm,h264,flac,hevc \
--disable-protocols \
--enable-protocol=file,async,concat,ffrtmphttp,rtmp*,rtmp,rtmpt,rtp,tcp \
--disable-protocol=bluray,ffrtmpcrypt,gopher,icecast,librtmp*,libssh,md5,mmsh,mmst,sctp,srtp,subfile,unix \
--enable-jni \
--enable-mediacodec \
--disable-demuxers \
--enable-demuxer=mp4,aac,mov,avi,concat,live_flv,hevc,flac,flv,rtsp,sdp,rtp,mjpeg,\
mp3,mpegps,mpegts,mpegvideo,data,webm_dash_manifest \
$ADDITIONAL_CONFIGURE_FLAG
make
make install

$TOOLCHAIN/bin/$CPU-linux-$ANDROID-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib \
-L$PREFIX/lib -soname libffmpeg.so \
-shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so \
$PREFIX/lib/libavcodec.a \
$PREFIX/lib/libpostproc.a \
$PREFIX/lib/libavfilter.a \
$PREFIX/lib/libswresample.a \
$PREFIX/lib/libavformat.a \
$PREFIX/lib/libavutil.a \
$PREFIX/lib/libswscale.a \
$x264/lib/libx264.a \
-lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker $TOOLCHAIN/lib/gcc/$CPU-linux-$ANDROID/4.9.x/libgcc.a
}
build_one