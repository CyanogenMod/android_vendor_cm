#!/bin/bash

CWD=`pwd`
WIDTH=$1
HEIGHT=$(echo "$WIDTH/1.6" | bc)
HALF_RES=$2
if [ "$HALF_RES" = "true" ]; then
    WIDTH=`expr $WIDTH / 2`
    HEIGHT=`expr $HEIGHT / 2`
fi

if [ -f "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip" ]; then
    echo "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip"
else
RESOLUTION=""$WIDTH"x"$HEIGHT""
set >blah

mkdir -p $ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/part{0..4}
tar xvfp "$PWD/vendor/cm/bootanimation/bootanimation.tar" --to-command="convert - -resize '$RESOLUTION' \"png8:$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/\$TAR_FILENAME\""
# create desc.txt
echo "$WIDTH" "$HEIGHT" 60 > "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/desc.txt"
cat "$PWD/vendor/cm/bootanimation/desc.txt" >> "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/desc.txt"

# create bootanimation.zip
cd "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation"
zip -r0 "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip" .
echo "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip"

fi

