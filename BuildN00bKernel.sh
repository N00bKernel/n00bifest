#!/bin/bash
sleep 10
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
# Configure Local Directories & Variables
#
# libncurses5 <-- bhosdiwala
# ARCH & SUBARCH
ARCH=arm64
SUBARCH=arm64
# workspace
WORKSPACE=~/Nooblab
# server root
SERVER_DIR=/var/www/html
# OTA server dir
OTA_DIR=N00bKernelDownloads
# devide dir
DEVICE_DIR=potter
# Toolchain dir
TOOLCHAIN_DIR=~/Toolchains
CLANG_DIR=AOSP/clang
GCC_DIR=AOSP/gcc
# device def_config
CONFIG=potter_defconfig
# CC flag
CC=clang
CLANG_TRIPLE_PREFIX=aarch64-linux-gnu-
CROSS_COMPILE_PREFIX=aarch64-linux-android-
# Kernel image Name
KERNEL=Image.gz
# No of jobs
JOBS=$(nproc --ignore 4)
#######################################################################
# kernel source dir
SOURCE_DIR=$WORKSPACE/source
# kernel build / work dir
OUT_DIR=$SOURCE_DIR/out
# kernel out dir
KERNEL_DIR=$OUT_DIR/arch/$ARCH/boot
# archiving dir
SHIPPING_DIR=$WORKSPACE/N00bKernel
# release dir
RELEASE_DIR=$WORKSPACE/N00bReleases
# N00bKernel update dir (on device)
DEVICE_UPDATE_DIR=/sdcard/N00bKernelUpdate
#
# Configure Environmental Variables
#
CLANG_PATH=$TOOLCHAIN_DIR/$CLANG_DIR
GCC_PATH=$TOOLCHAIN_DIR/$GCC_DIR
####################### Start The Shit #######################
# change directory to kernel source
cd $SOURCE_DIR/
# SET PATH FIRST
export PATH=$CLANG_PATH/bin:$GCC_PATH/bin:$PATH
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
if [ ! -d $OUT_DIR/ ]; then
    echo "[I] Creating Work Directory !"
    mkdir -p $OUT_DIR/
fi
make O=$OUT_DIR clean
make O=$OUT_DIR mrproper
# write device_defconfig to .config
make O=$OUT_DIR ARCH=$ARCH $CONFIG
# start build
echo "[I] kernel compiling started...."
make O=$OUT_DIR -j$JOBS ARCH=$ARCH CC=$CC CLANG_TRIPLE=$CLANG_TRIPLE_PREFIX CROSS_COMPILE=$CROSS_COMPILE_PREFIX
clear
echo "[I] kernel compiled...."
sleep 2
echo "[I] copying kernel to shipping directory...."
# copy compiled kernel to shipping directory
sleep 2
if [ ! -d $SHIPPING_DIR/ ]; then
    echo "[I] Creating Shipping Directory !"
    mkdir -p $SHIPPING_DIR/
fi
# change directory to shipping directory
cd $SHIPPING_DIR/
# remove old zip (here kept as backup)
echo "[I] removing older flashable zips & kernel...."
rm $KERNEL
rm N00bKernel-*.zip
cp $KERNEL_DIR/$KERNEL $SHIPPING_DIR/
# archive and make flashable zip
echo "[I] building flashable zip...."
make
sleep 5
if [ ! -d $RELEASE_DIR/ ]; then
    echo "[I] Creating Work Directory !"
    mkdir -p $RELEASE_DIR/
fi
# copy to release dir
echo "[I] copying flashable zip to release directory..."
cp $SHIPPING_DIR/N00bKernel-*.zip $RELEASE_DIR/
if [ ! -d $OTA_DIR/ ]; then
    echo "[I] Creating Work Directory !"
    mkdir -p $OTA_DIR/
fi
# copy to server
echo "[I] copying flashable zip to OTA server directory..."
sudo cp $SHIPPING_DIR/N00bKernel-*.zip $SERVER_DIR/$OTA_DIR/$DEVICE_DIR/
OTA_URL=$(ip route show | grep "src" | cut -d" " -f9)
echo ""
echo "[I] OTA URL : http://$OTA_URL"
echo ""
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
# verify the toolchain used
cat $OUT_DIR/include/generated/compile.h
