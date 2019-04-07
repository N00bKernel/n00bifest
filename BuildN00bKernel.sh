#!/bin/bash
clear
echo ""
echo " __    _  _______  _______  _______ "
echo "|  |  | ||  _    ||  _    ||  _    |"
echo "|   |_| || | |   || | |   || |_|   |"
echo "|       || | |   || | |   ||       |"
echo "|  _    || |_|   || |_|   ||  _   | "
echo "| | |   ||       ||       || |_|   |"
echo "|_|  |__||_______||_______||_______|"
echo " ___      _______  _______ "
echo "|   |    |   _   ||  _    |"
echo "|   |    |  |_|  || |_|   |"
echo "|   |    |       ||       |"
echo "|   |___ |       ||  _   | " 
echo "|       ||   _   || |_|   |"
echo "|_______||__| |__||_______|"
echo ""
echo "Scientist : chankruze"
echo "Company   : GEEKOFIA"
echo "Hobby     : Banging bitches like you !"
echo ""
####################### N00b Lab Initialization #######################
# set directories
# kernel source dir
SOURCE_DIR=~/AndroidSystemDev/potter/potter_kernel
# kernel build / work dir
WORK_DIR=~/AndroidSystemDev/potter/potter_kernel/out
# kernel out dir
KERNEL_DIR=~/AndroidSystemDev/potter/potter_kernel/out/arch/arm64/boot
# archiving dir
SHIPPING_DIR=~/AndroidSystemDev/potter/N00bKernel
# release dir
RELEASE_DIR=~/AndroidSystemDev/potter/N00bReleases
# OTA server dir
OTA_DIR=/var/www/html/N00bKernelDownloads
# N00bKernel update dir (on device)
DEVICE_UPDATE_DIR=/sdcard/N00bKernelUpdate
# Toolchain dir
TOOLCHAIN_DIR=~/AndroidSystemDev/aarch64-linux-android-4.9/bin
# ARCH & SUBARCH
ARCH=arm64
SUBARCH=arm64
####################### Start The Shit #######################
# set ARCH & SUBARCH 
export ARCH=$ARCH && export SUBARCH=$ARCH
# set TOOLCHAIN
export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-
# change directory to kernel source
cd $SOURCE_DIR/
# clean up old builds
make clean
make mrproper
if [ ! -d $WORK_DIR/ ]; then
    echo "[I] Creating Work Directory !"
    mkdir -p $WORK_DIR/
fi
make O=$WORK_DIR clean
make O=$WORK_DIR mrproper
# write device_defconfig to .config
make O=$WORK_DIR potter_defconfig
# start build
make O=$WORK_DIR -j$(nproc --ignore 4)
sleep 2
# change directory to shipping directory
cd $SHIPPING_DIR/
# remove old kernel & zip (here kept as backup)
rm Image.gz
rm N00bKernel-*.zip
# copy compiled kernel to shipping directory
cp $KERNEL_DIR/Image.gz $SHIPPING_DIR/
# archive and make flashable zip
make
sleep 5
# copy to release dir
cp $SHIPPING_DIR/N00bKernel-*.zip $RELEASE_DIR/
# copy to server
sudo cp $SHIPPING_DIR/N00bKernel-*.zip $OTA_DIR/
#
# Pushing Update To Device Via ADB
#
adb devices
adb kill-server
sleep 5
# push over local network
adb connect $(ip route show | grep "default via" | cut -d" " -f3)
sleep 5
adb devices
sleep 2
adb push N00bKernel-*.zip $DEVICE_UPDATE_DIR/
sleep 5
adb reboot recovery
# change directory back to kernel source (displacement = 0)
# clean source dir
cd $SOURCE_DIR
make clean
make mrproper
# clean out dir
make O=$WORK_DIR clean
make O=$WORK_DIR mrproper
