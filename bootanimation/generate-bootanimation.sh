#!/bin/bash

WIDTH="$1"
HEIGHT="$2"
HALF_RES="$3"
OUT="$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION"

if [ "$HEIGHT" -lt "$WIDTH" ]; then
    SIZE="$HEIGHT"
else
    SIZE="$WIDTH"
fi

if [ "$HALF_RES" = "true" ]; then
    IMAGESIZE=$(expr $SIZE / 2)
else
    IMAGESIZE="$SIZE"
fi

if [ ! -f "$BOOTANIMATION_OUT" ]; then
    RESOLUTION=""$IMAGESIZE"x"$IMAGESIZE""

    mkdir -p $ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/part{0..2}
    tar xfp "vendor/cm/bootanimation/bootanimation.tar" --to-command="convert - -resize '$RESOLUTION' \"png8:$OUT/bootanimation/\$TAR_FILENAME\""

    # Create desc.txt
    echo "$SIZE" "$SIZE" 30 > "$OUT/bootanimation/desc.txt"
    cat "vendor/cm/bootanimation/desc.txt" >> "$OUT/bootanimation/desc.txt"

    # Create bootanimation.zip
    cd "$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation"

    if [ ! -d "$ANDROID_PRODUCT_OUT/system/media" ]; then
        mkdir -p "$ANDROID_PRODUCT_OUT/system/media"
    fi

    zip -qr0 "$OUT/bootanimation.zip" .
fi
