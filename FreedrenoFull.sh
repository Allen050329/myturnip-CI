#!/bin/sh
green='\033[0;32m'
red='\033[0;31m'
nocolor='\033[0m'
workdir="$(pwd)/workdir"
magiskdir="$workdir/freedreno"
clear

echo "Prepare magisk module structure ..." $'\n'
p1="system/vendor/lib64/egl"
p2="system/vendor/lib/egl"
p3="system/vendor/lib64/hw"
p4="system/vendor/lib/hw"
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
id=freedreno_full
name=Freedreno Full
version=v23.0.0
versionCode=1-r1
author=Allen050329
description=Freedreno is an open-source driver set for devices with adreno GPUs.
EOF



cat <<EOF >"customize.sh"
set_perm \$MODPATH/$p1/libEGL_adreno.so 0 0 0644
set_perm \$MODPATH/$p1/libGLESv1_CM_adreno.so 0 0 0644
set_perm \$MODPATH/$p1/libGLESv2_adreno.so 0 0 0644
set_perm \$MODPATH/$p2/libEGL_adreno.so 0 0 0644
set_perm \$MODPATH/$p2/libGLESv1_CM_adreno.so 0 0 0644
set_perm \$MODPATH/$p2/libGLESv2_adreno.so 0 0 0644
set_perm \$MODPATH/$p3/vulkan.adreno.so 0 0 0644
set_perm \$MODPATH/$p4/vulkan.adreno.so 0 0 0644
EOF



echo "Copy necessary files from work directory ..." $'\n'
cp $workdir/vulkan.adreno.so $magiskdir/$p3
cp -a $magiskdir/$p3 $magiskdir/$p4

cp $workdir/libEGL_adreno.so $magiskdir/$p1
cp $workdir/libGLESv1_CM_adreno.so $magiskdir/$p1
cp $workdir/libGLESv2_adreno.so $magiskdir/$p1
cp -a $magiskdir/$p1 $magiskdir/$p2


echo "Packing files in to magisk module ..." $'\n'
zip -r $workdir/FreedrenoFull.zip * &> /dev/null
if ! [ -a $workdir/FreedrenoFull.zip ];
	then echo -e "$red-Packing failed!$nocolor" && exit 1
	else echo -e "$green-All done, you can take your module from here;$nocolor" && echo $workdir/FreedrenoGL.zip
fi