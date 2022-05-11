#!/bin/bash

# prepare for init variables
if [ $# -ge 3 ]; then
    AOSP_HOME=$1
    FAKE_AOSP_HOME=$2
    IF_USE_EMULATOR=$3
elif [ $# -le 2 ]; then
    AOSP_HOME=${1-"~/aosp"}
    FAKE_AOSP_HOME=${2-"~/fake"}
    IF_USE_EMULATOR=""
    # if not export ANDROID_HOME, return error
    if [ -z $ANDROID_HOME ]; then
        return
    fi
    ANDROID_SDK_HOME=$ANDROID_HOME
fi

# define source dir and target dir
AOSP_PREBUILTS=$AOSP_HOME/prebuilts/android-emulator/linux-x86_64
AOSP_PRODUCT_OUT=$AOSP_HOME/out/target/product/emulator_x86_64
FAKE_AOSP_PREBUILTS=$FAKE_AOSP_HOME/prebuilts/android-emulator/linux-x86_64
FAKE_AOSP_PRODUCT_OUT=$FAKE_AOSP_HOME/out/target/product/emulator_x86_64

# used to copy out files to target dir
function cp_essential_out_files() {
    local dst_dir=$2
    local src_dir=$1
    if [ ! -d "$dst_dir" ]; then
	mkdir -p $dst_dir
    elif [ $(ls $dst_dir | wc -l) -ge 16 ]; then
	echo "essential out files have been copied"
	return
    fi

    files=("advancedFeatures.ini" "build.avd" "config.ini" "encryptionkey.img" "hardware-qemu.ini" "initrd" "kernel-ranchu" "ramdisk.img" "ramdisk-qemu.img" "system" "system.img" "system-qemu.img" "userdata.img" "userdata-qemu.img" "vendor.img" "VerifiedBootParams.textproto")
    for file in ${files[@]}
    do
	cp -r $src_dir/$file $dst_dir
    done
}

# used to copy prebuilts files to target dir
function cp_essential_prebuilts_files() {
    local dst_dir=$2
    local src_dir=$1
    if [ ! -d "$dst_dir" ]; then
	mkdir -p $dst_dir
    elif [ $(ls $dst_dir | wc -l) -eq 4 ]; then
	echo "essential prebuilts files have been copied"
	return
    fi

    files=("emulator" "lib" "lib64" "qemu")
    for file in ${files[@]}
    do
	cp -r $src_dir/$file $dst_dir
    done
}

if [ ! -d "$FAKE_AOSP_HOME" ]; then
    mkdir -p $FAKE_AOSP_HOME
fi

cp_essential_out_files $AOSP_PRODUCT_OUT $FAKE_AOSP_PRODUCT_OUT
# this if-statement is design to enable emulator under AOSP/prebuilts
if [ "$IF_USE_EMULATOR" = "--aosp-emulator" -o "$IF_USE_EMULATOR" = "-ae" ]; then
    cp_essential_prebuilts_files $AOSP_PREBUILTS $FAKE_AOSP_PREBUILTS
    EMULATOR_PATH=$FAKE_AOSP_HOME/prebuilts/android-emulator/linux-x86_64
    export PATH=$PATH:$EMULATOR_PATH
else
    export PATH=$PATH:$ANDROID_SDK_HOME/emulator
fi

# export environment variables for emulator working in Android build system mode
export ANDROID_BUILD_TOP=$FAKE_AOSP_HOME
export ANDROID_PRODUCT_OUT=$FAKE_AOSP_HOME/out/target/product/emulator_x86_64
