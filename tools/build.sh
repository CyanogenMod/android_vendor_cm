#!/bin/bash
# Usage build.sh <device>
# Checks for user name
#

# ---------------------------------------------------------
# >>> Init Vars
  HOMEDIR=${PWD}
# ---------------------------------------------------------

# ---------------------------------------------------------
# >>> AOSP 4.3 for S4 (i9505)
# >>> Copyright 2013 broodplank.net
# >>> REV3
# ---------------------------------------------------------

usage()
{
	echo -e ""
	echo -e $CL_BOL"Usage:"$CL_RST
	echo -e "  build.sh [options] device"
	echo -e ""
	echo -e $CL_BOL"  Options:"$CL_RST
	echo -e "    -c  Clean before the build"
	echo -e "    -d  Use debugging file build.log"
	echo -e "    -j# Set jobs"
	echo -e ""
	echo -e $CL_BOL"  Example:"$CL_RST
	echo -e "    ./build.sh -c jfltetmo"
	echo -e ""
	exit 1
}


# are in an Android Build 

if [ ! -d ".repo" ]; then
          echo -e $CL_RED"No .repo directory found."$CL_RST
          exit 1
fi

# build the options for the Menu
./prebuilts/misc/linux-x86/ccache/ccache -M 50G
opt_clean=0
opt_deb=0
opt_jobs="$CPUS"
opt_sync=0

while getopts "cdjL:s" opt; do
	case "$opt" in
	c) opt_clean=1 ;;
	d) opt_deb=1 ;;
	j) opt_jobs="$OPTARG" ;;
        L) opt_log=1 ;;
	s) opt_sync=1 ;;
	*) usage
	esac
done
shift $((OPTIND-1))
if [ "$#" -ne 1 ]; then
	usage
fi
device="$1"

if [ "$opt_clean" -ne 0 ]; then
	make clean >/dev/null
fi


rm -f out/target/product/$device/obj/KERNEL_OBJ/.version

if [ "$opt_deb" -ne 0 ]; then
       exec > >(tee build.log ) 
fi

# get username for bionic issue
export USEROLD=`whoami`;
export ULENGTH=`expr length ${USEROLD}`
if [[ ${ULENGTH} -gt 9 ]]; then
        clear
        echo
        echo
        echo
        echo "Your username seems to exceed the max of 9 characters (${ULENGTH} chars)"
        echo "Due to a temp issue with bionic the max amount of characters is limited."
        echo "If the limit is exceeded the camera refuses to take pictures"
        echo 
        echo "Do you want to pick a new username right now that's below 9 chars? ( y / n )"
        read choice
        echo
        if [[ ${choice} == "n" ]]; then
                echo "Taking pictures with camera won't work, you're warned!"
                echo
                echo "Continuing..."
        else
                echo "New username:"
                read username
                export USER=${username}
                echo
                echo "Replacing current username ${USEROLD} with new username ${choice}"
                echo        
        fi;
fi;

# Remove system folder (this will create a new build.prop with updated build time and date)
rm -f out/target/product/$device/system/build.prop
rm -f out/target/product/$device/system/app/*.odex
rm -f out/target/product/$device/system/framework/*.odex

# Starting Timer
START=$(date +%s)
THREADS=`cat /proc/cpuinfo | grep processor | wc -l`

# setup environment
echo -e $CL_BLU"Setting up environment"$CL_RST
. build/envsetup.sh && brunch $device -j"$opt_jobs"

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n" $E_SEC
echo ""
echo ""
echo ""



