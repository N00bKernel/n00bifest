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
# Configure Local Directories & Variables
#
# libncurses5 <-- bhosdiwala
# ARCH & SUBARCH
DEVICE_CODE=
ARCH=arm64
SUBARCH=arm64
# workspace
WORKSPACE=~/Nooblab
# server root
SERVER_DIR=/var/www/html
# OTA server dir
OTA_DIR=N00bKernelDownloads
# devide dir
DEVICE_DIR=$DEVICE_CODE
# Toolchain dir
TOOLCHAIN_DIR=~/Toolchains
# Clang dir
CLANG_DIR=DTC/clang
# GCC dir
GCC_DIR=DTC/gcc
#############################################################
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
# Clang & GCC PATH
CLANG_PATH=$TOOLCHAIN_DIR/$CLANG_DIR
GCC_PATH=$TOOLCHAIN_DIR/$GCC_DIR
#############################################################
# Prefix & flags
CC=clang
CLANG_TRIPLE_PREFIX=aarch64-linux-gnu-
CROSS_COMPILE_PREFIX=aarch64-linux-gnu-
# Kernel image Name
KERNEL=Image.gz-dtb
#
# Build details
#
CONFIG=${DEVICE_CODE}_defconfig
BUILD_VARIANT_01=N00bKernel-$DEVICE_CODE
# BUILD_VARIANT_02=N00bKernel-400Hz
KERNEL_VERSION=0.0.0
# No of jobs
JOBS=$(nproc --all)
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
#####################
# Check Clang & GCC #
#####################
echo "==========================="
echo " CLANG_PATH = ${CLANG_PATH}"
echo " GCC_PATH = ${GCC_PATH}"
echo "==========================="
echo " CC = ${CC}"
echo " CLANG_TRIPLE = ${CLANG_TRIPLE}"
echo " CROSS_COMPILE = ${CROSS_COMPILE}"
echo "==========================="
##########################
# Out/Building Directory #
##########################
if [ ! -d $OUT_DIR/ ]; then
    echo "[I] Creating Work Directory !"
    mkdir -p $OUT_DIR/
fi
make O=$OUT_DIR clean
make O=$OUT_DIR mrproper
# write device_defconfig to .config
make O=$OUT_DIR ARCH=$ARCH $CONFIG
make O=$OUT_DIR menuconfig
# start build
echo "[I] kernel compiling started...."
make O=$OUT_DIR -j$JOBS ARCH=$ARCH CC=$CC CLANG_TRIPLE=$CLANG_TRIPLE_PREFIX CROSS_COMPILE=$CROSS_COMPILE_PREFIX
# clear
# echo "[I] kernel compiled...."
# sleep 2
# echo "[I] copying kernel to shipping directory...."
# # copy compiled kernel to shipping directory
# sleep 2
# ######################
# # Shipping Directory #
# ######################
# if [ ! -d $SHIPPING_DIR/ ]; then
#     echo "[I] Creating Shipping Directory !"
#     mkdir -p $SHIPPING_DIR/
#     echo "[I] Setting Up Shipping Directory !"
#     git clone https://github.com/N00bKernel/FlashableArchive.git $SHIPPING_DIR
# fi
# # change directory to shipping directory
# cd $SHIPPING_DIR/
# # remove old zip (here kept as backup)
# echo "[I] removing older flashable zips & kernel...."
# rm $KERNEL
# rm N00bKernel-*.zip *.sha1
# cp $KERNEL_DIR/$KERNEL $SHIPPING_DIR/
# # archive and make flashable zip
# echo "[I] building flashable zip...."
# make NAME=$BUILD_VARIANT_02 VERSION=$KERNEL_VERSION
# sleep 5
# #####################
# # Release Directory #
# #####################
# if [ ! -d $RELEASE_DIR/ ]; then
#     echo "[I] Creating Release Directory !"
#     mkdir -p $RELEASE_DIR/
# fi
# # copy to release dir
# echo "[I] copying flashable zip to release directory..."
# cp $SHIPPING_DIR/N00bKernel-*.zip $RELEASE_DIR/
# ##############
# # OTA Server #
# ##############
# if [ ! -d $SERVER_DIR/$OTA_DIR/ ]; then
#     echo "[I] Creating OTA Directory !"
#     mkdir -p $SERVER_DIR/$OTA_DIR/
#     git clone https://github.com/N00bKernel/OTA_DIR.git $SERVER_DIR/$OTA_DIR/
# fi
# if [ ! -d $SERVER_DIR/$OTA_DIR/$DEVICE_DIR/ ]; then
#     echo "[I] Creating Device Dir In OTA Directory !"
#     mkdir -p $SERVER_DIR/$OTA_DIR/$DEVICE_DIR/
# fi
# # copy to server
# echo "[I] copying flashable zip to OTA server directory..."
# sudo cp $SHIPPING_DIR/N00bKernel-*.zip $SERVER_DIR/$OTA_DIR/$DEVICE_DIR/
# OTA_URL=$(ip route show | grep "src" | cut -d" " -f9)
# echo "==========================="
# echo "[I] OTA URL : http://$OTA_URL"
# echo "==========================="
cat $OUT_DIR/include/generated/compile.h
