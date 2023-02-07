#!/bin/sh
green='\033[0;32m'
red='\033[0;31m'
nocolor='\033[0m'
deps="meson ninja patchelf unzip git curl pip flex bison zip"
depdir="$(pwd)/depend"
workdir="$(pwd)/workdir"
magiskdir="$workdir/magisk_panfrost_mali"
andk="android-ndk"
ndkrev="r25b"
clear



echo "Checking system for required Dependencies ..."
for deps_chk in $deps;
	do 
		sleep 0.25
		if command -v $deps_chk >/dev/null 2>&1 ; then
			echo -e "$green - $deps_chk found $nocolor"
		else
			echo -e "$red - $deps_chk not found, can't countinue. $nocolor"
			deps_missing=1
		fi;
	done
	
	if [ "$deps_missing" == "1" ]
		then echo "Please install missing dependencies" && exit 1
	fi



echo "Installing python Mako dependency (if missing) ..." $'\n'
pip install mako 


if [ ! -d $workdir ]; then
	echo "Creating and entering to work directory ..." $'\n'
	mkdir -p $workdir
else
	echo "$workdir exists! Entering ..." $'\n'
fi

cd $workdir

if [ ! -d "$andk/toolchains" ]; then
	echo "Downloading android-ndk from google server ..." $'\n'
	curl https://dl.google.com/android/repository/$andk-$ndkrev-linux.zip --output $andk-linux.zip 
	###
	echo "Exracting android-ndk to a folder ..." $'\n'
	unzip $andk-linux.zip &> /dev/null
	cp -a $andk-$ndkrev $andk
	rm -rf $andk-linux.zip $andk-$ndkrev
else
	echo  "NDK $andk exists!" $'\n'
fi

if [ ! -d mesa ]; then
	echo "Downloading mesa source ..." $'\n'
	git clone https://gitlab.freedesktop.org/mesa/mesa.git
	###
else
	echo "$workdir/mesa exists! Entering ..." $'\n'
fi

cd mesa

ndk="$workdir/$andk/toolchains/llvm/prebuilt/linux-x86_64/bin"
INC_DIR="$depdir/deps"
LD_LIBRARY_PATH="$ndk:$depdir/deps:/usr/include:$LIBRARY_PATH:$LD_LIBRARY_PATH"
LIBRARY_PATH="$LD_LIBRARY_PATH"
LOCAL_C_INCLUDES="$LIBRARY_PATH"
LOCAL_CXX_INCLUDES="$LIBRARY_PATH"
CMAKE_CXX_FLAGS="-I$INC_DIR"
DEPS="$depdir/deps/libdrm/xf86drm.h"
rm -rf ./build-android-aarch64 ./android-aarch64


echo "Creating meson cross file ..." $'\n'
cat <<EOF >"android-aarch64"
[binaries]
ar = '$ndk/llvm-ar'
c = ['ccache', '$ndk/aarch64-linux-android33-clang', '-O3']
cpp = ['ccache', '$ndk/aarch64-linux-android33-clang++', '-O3', '-fno-rtti', '-fno-exceptions', '-fno-unwind-tables', '-fno-asynchronous-unwind-tables', '-static-libstdc++']
c_ld = '$ndk/ld.lld'
cpp_ld = '$ndk/ld.lld'
llvm-config = '$ndk/llvm-config'
strip = '$ndk/aarch64-linux-android-strip'
pkgconfig = ['env', 'PKG_CONFIG_LIBDIR=$depdir/pkgconfig', '/usr/bin/pkg-config']
[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8'
endian = 'little'
EOF



echo "Generating build files ..." $'\n'
meson build-android-aarch64 --cross-file $workdir/mesa/android-aarch64 -Dshader-cache-max-size=36 \
       -Dbuildtype=debug -Dplatforms=android -Dplatform-sdk-version=31 -Dpower8=enabled  \
       -Dandroid-stub=true -Dgallium-drivers= -Dvulkan-drivers=panfrost -Dshader-cache=enabled \
	   -Db_lto=true -Dcpp_rtti=false -Dvulkan-beta=true -Dshader-cache-default=true \
       -Dvideo-codecs=vc1dec,h264dec,h264enc,h265dec,h265enc -Dllvm=enabled 2>&1 | tee $workdir/meson_log_mali.log



echo "Compiling build files ..." $'\n'
ninja -C build-android-aarch64 2>&1 | tee $workdir/ninja_log_mali.log



#echo "Using patchelf to match soname ..."  $'\n'
cp $workdir/mesa/build-android-aarch64/src/panfrost/vulkan/libvulkan_panfrost.so $workdir
cd $workdir
#patchelf --set-soname vulkan.adreno.so libvulkan_panfrost.so
#mv libvulkan_panfrost.so vulkan.adreno.so



if ! [ -a libvulkan_panfrost.so ]; then
	echo -e "$red Build failed! $nocolor" && exit 1
fi



echo "Prepare magisk module structure ..." $'\n'
p1="system/vendor/lib64/hw"
p2="system/vendor/lib/hw"
mkdir -p $magiskdir/$p1
cd $magiskdir



meta="META-INF/com/google/android"
mkdir -p $meta



cat <<EOF >"$meta/update-binary"
#################
# Initialization
#################
umask 022
# echo before loading util_functions
ui_print() { echo "\$1"; }
require_new_magisk() {
  ui_print "*******************************"
  ui_print " Please install Magisk v20.4+! "
  ui_print "*******************************"
  exit 1
}
#########################
# Load util_functions.sh
#########################
OUTFD=\$2
ZIPFILE=\$3
[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
. /data/adb/magisk/util_functions.sh
[ \$MAGISK_VER_CODE -lt 20400 ] && require_new_magisk
install_module
exit 0
EOF



cat <<EOF >"$meta/updater-script"
#MAGISK
EOF



cat <<EOF >"module.prop"
id=panfrost
name=Mesa Panfrost Debug
version=v23.0.0
versionCode=1
author=Rofik/XiaomiPocoMod
description=Panfrost is an open-source vulkan driver for devices with MALI GPUs.
EOF



cat <<EOF >"customize.sh"
set_perm \$MODPATH/$p1/libvulkan_panfrost.so 0 0 0644
set_perm \$MODPATH/$p2/libvulkan_panfrost.so 0 0 0644
EOF



echo "Copy necessary files from work directory ..." $'\n'
cp $workdir/libvulkan_panfrost.so $magiskdir/$p1
cp -a $magiskdir/$p1 $magiskdir/$p2


echo "Packing files in to magisk module ..." $'\n'
zip -r $workdir/panfrostmali.zip * &> /dev/null
if ! [ -a $workdir/panfrostmali.zip ];
	then echo -e "$red-Packing failed!$nocolor" && exit 1
	else echo -e "$green-All done, you can take your module from here;$nocolor" && echo $workdir/panfrostmali.zip
fi
