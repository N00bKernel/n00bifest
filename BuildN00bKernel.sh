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
# 
# Configure Local Directories
#
# kernel source dir
SOURCE_DIR=~/AndroidSystemDev/potter/potter_kernel
# kernel build / work dir
WORK_DIR=~/AndroidSystemDev/potter/potter_kernel/out
# kernel out dir
KERNEL_DIR=~/AndroidSystemDev/potter/potter_kernel/out/arch/arm64/boot
# archiving dir
SHIPPING_DIR=~/AndroidSystemDev/potter/lazyflasher
# release dir
RELEASE_DIR=~/AndroidSystemDev/potter/N00bReleases
# OTA server dir
OTA_DIR=/var/www/html/N00bKernelDownloads
# N00bKernel update dir (on device)
DEVICE_UPDATE_DIR=/sdcard/N00bKernelUpdate
# Toolchain dir
TOOLCHAIN_DIR=~/AndroidSystemDev/aarch64-linux-android-4.9/bin
#
# Configure Environmental Variables
#
# ARCH & SUBARCH
ARCH=arm64
SUBARCH=arm64
CONFIG=potter_defconfig
# SET PATH FIRST
# PATH="<path to clang folder>/bin:<path to gcc folder>/bin:${PATH}"
CC=clang
CLANG_TRIPLE=aarch64-linux-gnu-
CROSS_COMPILE=aarch64-linux-android-
# No of jobs
JOBS=$(nproc --ignore 4)
# Kernel image Name
KERNEL=Image.gz
####################### Start The Shit #######################
# set ARCH & SUBARCH 
export ARCH=$ARCH
export SUBARCH=$ARCH
# set TOOLCHAIN
export CC=$CC
export CLANG_TRIPLE=$CLANG_TRIPLE
export CROSS_COMPILE=$CROSS_COMPILE
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
make O=$WORK_DIR $CONFIG
# start build
make O=$WORK_DIR -j$JOBS
sleep 2
# copy compiled kernel to shipping directory
cp $KERNEL_DIR/$KERNEL $SHIPPING_DIR/
sleep 2
# change directory to shipping directory
cd $SHIPPING_DIR/
# remove old zip (here kept as backup)
rm N00bKernel-*.zip
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
