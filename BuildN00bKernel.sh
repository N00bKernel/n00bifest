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
CC=clang
CLANG_DIR=~/AndroidSystemDev/linux-x86-android-9.0.0_r1-clang-4691093
GCC_DIR=~/AndroidSystemDev/aarch64-linux-android-4.9
CLANG_TRIPLE_PREFIX=aarch64-linux-gnu-
CROSS_COMPILE_PREFIX=aarch64-linux-android-
# No of jobs
JOBS=$(nproc --ignore 4)
# Kernel image Name
KERNEL=Image.gz
####################### Start The Shit #######################
# change directory to kernel source
cd $SOURCE_DIR/
# SET PATH FIRST
export PATH=$CLANG_DIR/bin:$GCC_DIR/bin:$PATH
# set ARCH & SUBARCH 
export ARCH=$ARCH
export SUBARCH=$ARCH
# set TOOLCHAIN
export CC=$CC
export CLANG_TRIPLE=$CLANG_TRIPLE_PREFIX
export CROSS_COMPILE=$CROSS_COMPILE_PREFIX
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
make O=$WORK_DIR ARCH=$ARCH $CONFIG
# start build
echo "[I] kernel compiling started...."
make O=$WORK_DIR -j$JOBS ARCH=$ARCH CC=$CC CLANG_TRIPLE=$CLANG_TRIPLE_PREFIX CROSS_COMPILE=$CROSS_COMPILE_PREFIX
clean
echo "[I] kernel compiled...."
sleep 2
echo "[I] copying kernel to shipping directory...."
# copy compiled kernel to shipping directory
cp $KERNEL_DIR/$KERNEL $SHIPPING_DIR/
sleep 2
# change directory to shipping directory
cd $SHIPPING_DIR/
# remove old zip (here kept as backup)
echo "[I] removing older flashable zips...."
rm N00bKernel-*.zip
# archive and make flashable zip
echo "[I] building flashable zip...."
make
sleep 5
# copy to release dir
echo "[I] copying flashable zip to release directory..."
cp $SHIPPING_DIR/N00bKernel-*.zip $RELEASE_DIR/
# copy to server
echo "[I] copying flashable zip to OTA server directory..."
sudo cp $SHIPPING_DIR/N00bKernel-*.zip $OTA_DIR/
#
# Pushing Update To Device Via ADB
#
adb devices
adb kill-server
sleep 5
# push over local network
echo "[I] connecting to device over local network...."
adb connect $(ip route show | grep "default via" | cut -d" " -f3)
sleep 5
adb devices
adb push N00bKernel-*.zip $DEVICE_UPDATE_DIR/
sleep 5
echo "[I] rebooting device to recovery mode...."
adb reboot recovery
# change directory back to kernel source (displacement = 0)
# clean source dir
cd $SOURCE_DIR
echo "[I] cleaning working directory...."
make clean
make mrproper
# clean out dir
make O=$WORK_DIR clean
make O=$WORK_DIR mrproper
