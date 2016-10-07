#!/bin/bash

CWD=`pwd`
WIDTH=$1
RWIDTH=$WIDTH
HALF_RES=$2
if [ "$HALF_RES" = "true" ]; then
    WIDTH=`expr $WIDTH / 2`
fi

if [ ! -f "/usr/bin/convert" ]; then
$(info **********************************************)
$(info The boot animation could not be generated as)
$(info ImageMagick is not installed in your system.)
$(info $(space))
$(info Please install ImageMagick from this website:)
$(info $(space)$(space)$(space)$(space)https://imagemagick.org/script/binary-releases.php)
$(info **********************************************)
$(error stop)
fi

if [ -f "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip" ]; then
    echo "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip"
else
RESOLUTION=""$WIDTH"x"$WIDTH""

mkdir -p $ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/part{0..2}
tar xvfp "$PWD/vendor/cm/bootanimation/bootanimation.tar" --to-command="convert - -resize '$RESOLUTION' \"png8:$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/\$TAR_FILENAME\""
# Create desc.txt
echo "$RWIDTH" "$RWIDTH" 30 > "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/desc.txt"
cat "$PWD/vendor/cm/bootanimation/desc.txt" >> "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/desc.txt"

# Create bootanimation.zip
cd "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation"

if [ ! -d "$ANDROID_PRODUCT_OUT/system/media" ]; then
mkdir -p "$ANDROID_PRODUCT_OUT/system/media"
fi

zip -r0 "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip" .
echo "$ANDROID_PRODUCT_OUT/system/media/bootanimation.zip"

fi
