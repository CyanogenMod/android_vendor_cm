#!/bin/bash

CWD=`pwd`
WIDTH=$1
HEIGHT=$2
HALF_RES=$3

if [ "$HEIGHT" -lt "$WIDTH" ]; then
    SIZE=$HEIGHT
else
    SIZE=$WIDTH
fi

if [ "$HALF_RES" = "true" ]; then
    IMAGESIZE=`expr $SIZE / 2`
else
    IMAGESIZE=$SIZE
fi

if [ -f "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip" ]; then
    echo "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip"
else
RESOLUTION=""$IMAGESIZE"x"$IMAGESIZE""

mkdir -p $ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/part{0..2}
tar xvfp "$PWD/vendor/cm/bootanimation/bootanimation.tar" --to-command="convert - -resize '$RESOLUTION' \"png8:$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/\$TAR_FILENAME\""
# Create desc.txt
echo "$SIZE" "$SIZE" 30 > "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/desc.txt"
cat "$PWD/vendor/cm/bootanimation/desc.txt" >> "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/desc.txt"

# Create bootanimation.zip
cd "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation"

if [ ! -d "$ANDROID_PRODUCT_OUT/system/media" ]; then
mkdir -p "$ANDROID_PRODUCT_OUT/system/media"
fi

zip -r0 "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip" .
echo "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip"

fi
