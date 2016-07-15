#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if [ -z "$DEVICE" ]; then
    echo "\$DEVICE must be set before including this script!"
    exit 1
fi

if [ -z "$VENDOR" ]; then
    echo "\$VENDOR must be set before including this script!"
    exit 1
fi

if [ ! -d "$CM_ROOT" ]; then
    echo "\$CM_ROOT must be set before including this script!"
    exit 1
fi

OUTDIR=vendor/$VENDOR/$DEVICE
export PRODUCTMK=$CM_ROOT/$OUTDIR/$DEVICE-vendor.mk
export ANDROIDMK=$CM_ROOT/$OUTDIR/Android.mk
export BOARDMK=$CM_ROOT/$OUTDIR/BoardConfigVendor.mk
PACKAGE_LIST=()

function prefix_match() {
    local prefix=$1
    shift
    local ary=( $@ )
    printf '%s\n' "${ary[@]}" | egrep "^$prefix" | sed -e "s#^$prefix##g"
}

function write_copy_list() {
    local FILELIST=( $(egrep -v '(^-|^#|^[[:space:]]*$)' "$1" | sort | uniq) )
    local COUNT=${#FILELIST[@]}

    if [ "$COUNT" = "0" ]; then
        return 0
    fi
    echo "PRODUCT_COPY_FILES += \\" >> "$PRODUCTMK"
    for FILE in "${FILELIST[@]}"; do
      # Split the file from the destination (format is "file[:destination]")
      local OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
      if [ -z "${PARSING_ARRAY[@]}" ]; then continue; fi
      local TARGET="${PARSING_ARRAY[0]}"
      local DEST=${PARSING_ARRAY[1]}
      if [ -n "$DEST" ]; then
          TARGET=$DEST
      fi
      echo "    $OUTDIR/proprietary/$TARGET:system/$TARGET \\" >> "$PRODUCTMK"
    done
    echo "" >> $PRODUCTMK
    return 0
}

function write_packages() {
    local CLASS="$1"
    shift
    local VENDOR_PKG="$1"
    shift
    local PRIVILEGED="$1"
    shift
    local MULTILIB="$1"
    shift

    for FILE in $@; do
      local BASENAME=$(basename "$FILE")
      local EXTENSION=${BASENAME##*.}
      local PKGNAME=${BASENAME%.*}

      PACKAGE_LIST+=("$PKGNAME")

      local SRC="proprietary"
      if [ "$VENDOR_PKG" = "true" ]; then
          SRC="$SRC/vendor"
      fi

      echo "include \$(CLEAR_VARS)"
      echo "LOCAL_MODULE := $PKGNAME"
      echo "LOCAL_MODULE_OWNER := $VENDOR"
      if [ "$CLASS" = "SHARED_LIBRARIES" ]; then
        if [ "$MULTILIB" = "both" ]; then
          echo "LOCAL_SRC_FILES_64 := $SRC/lib64/$FILE"
          echo "LOCAL_SRC_FILES_32 := $SRC/lib/$FILE"
          #if [ "$VENDOR_PKG" = "true" ]; then
          #  echo "LOCAL_MODULE_PATH_64 := \$(TARGET_OUT_VENDOR_SHARED_LIBRARIES)"
          #  echo "LOCAL_MODULE_PATH_32 := \$(2ND_TARGET_OUT_VENDOR_SHARED_LIBRARIES)"
          #else
          #  echo "LOCAL_MODULE_PATH_64 := \$(TARGET_OUT_SHARED_LIBRARIES)"
          #  echo "LOCAL_MODULE_PATH_32 := \$(2ND_TARGET_OUT_SHARED_LIBRARIES)"
          #fi
        elif [ "$MULTILIB" = "64" ]; then
          echo "LOCAL_SRC_FILES := $SRC/lib64/$FILE"
        else
          echo "LOCAL_SRC_FILES := $SRC/lib/$FILE"
        fi
        if [ "$MULTILIB" != "none" ]; then
          echo "LOCAL_MULTILIB := $MULTILIB"
        fi
      elif [ "$CLASS" = "APPS" ]; then
        if [ "$PRIVILEGED" = "true" ]; then
          SRC="$SRC/priv-app"
        else
          SRC="$SRC/app"
        fi
        echo "LOCAL_SRC_FILES := $SRC/$FILE"
        echo "LOCAL_CERTIFICATE := platform"
      elif [ "$CLASS" = "JAVA_LIBRARIES" ]; then
        echo "LOCAL_SRC_FILES := $SRC/framework/$FILE"
      elif [ "$CLASS" = "ETC" ]; then
        echo "LOCAL_SRC_FILES := $SRC/etc/$FILE"
      elif [ "$CLASS" = "EXECUTABLES" ]; then
        echo "LOCAL_SRC_FILES := $SRC/bin/$FILE"
      else
        echo "LOCAL_SRC_FILES := $SRC/$FILE"
      fi
      echo "LOCAL_MODULE_TAGS := optional"
      echo "LOCAL_MODULE_CLASS := $CLASS"
      echo "LOCAL_MODULE_SUFFIX := .$EXTENSION"
      if [ "$PRIVILEGED" = "true" ]; then
        echo "LOCAL_PRIVILEGED_MODULE := true"
      fi
      if [ "$VENDOR_PKG" = "true" ]; then
        echo "LOCAL_PROPRIETARY_MODULE := true"
      fi
      echo "include \$(BUILD_PREBUILT)"
      echo ""
    done
}

function write_module_list() {
  local P=($(egrep '(^-)' "$1" | sed -e "s/^-//g" | sort | uniq))
  local COUNT=${#P[@]}
  local PACKAGES="${P[*]}"

  PACKAGE_LIST=()

  if [ "$COUNT" = "0" ]; then
      return 0
  fi

  # Figure out what's 32-bit, what's 64-bit, and what's multilib
  # I really should not be doing this in bash :(
  local T_LIB32=$(prefix_match "lib/" "$PACKAGES")
  local T_LIB64=$(prefix_match "lib64/" "$PACKAGES")
  local MULTILIB=$(comm -12 <(echo "$T_LIB32") <(echo "$T_LIB64"))
  local LIB32=$(comm -23 <(echo "$T_LIB32") <(echo "$MULTILIB"))
  local LIB64=$(comm -13 <(echo "$T_LIB64") <(echo "$MULTILIB"))

  if [ ! -z "$MULTILIB" ]; then
    write_packages "SHARED_LIBRARIES" "false" "false" "both" "$MULTILIB" >> "$ANDROIDMK"
  fi
  if [ ! -z "$LIB32" ]; then
    write_packages "SHARED_LIBRARIES" "false" "false" "32" "$LIB32" >> "$ANDROIDMK"
  fi
  if [ ! -z "$LIB64" ]; then
    write_packages "SHARED_LIBRARIES" "false" "false" "64" "$LIB64" >> "$ANDROIDMK"
  fi

  local T_V_LIB32=$(prefix_match "vendor/lib/" "$PACKAGES")
  local T_V_LIB64=$(prefix_match "vendor/lib64/" "$PACKAGES")
  local V_MULTILIB=$(comm -12 <(echo "$T_V_LIB32") <(echo "$T_V_LIB64"))
  local V_LIB32=$(comm -23 <(echo "$T_V_LIB32") <(echo "$V_MULTILIB"))
  local V_LIB64=$(comm -13 <(echo "$T_V_LIB64") <(echo "$V_MULTILIB"))

  if [ ! -z "$V_MULTILIB" ]; then
    write_packages "SHARED_LIBRARIES" "true" "false" "both" "$V_MULTILIB" >> "$ANDROIDMK"
  fi
  if [ ! -z "$V_LIB32" ]; then
    write_packages "SHARED_LIBRARIES" "true" "false" "32" "$V_LIB32" >> "$ANDROIDMK"
  fi
  if [ ! -z "$V_LIB64" ]; then
    write_packages "SHARED_LIBRARIES" "true" "false" "64" "$V_LIB64" >> "$ANDROIDMK"
  fi

  # Apps
  local APPS=$(prefix_match "app/" "$PACKAGES")
  if [ ! -z "$APPS" ]; then
    write_packages "APPS" "false" "false" "none" "$APPS" >> "$ANDROIDMK"
  fi
  local PRIV_APPS=$(prefix_match "priv-app/" "$PACKAGES")
  if [ ! -z "$PRIV_APPS" ]; then
    write_packages "APPS" "false" "true" "none" "$PRIV_APPS" >> "$ANDROIDMK"
  fi
  local V_APPS=$(prefix_match "vendor/app/" "$PACKAGES")
  if [ ! -z "$V_APPS" ]; then
    write_packages "APPS" "true" "false" "none" "$V_APPS" >> "$ANDROIDMK"
  fi
  local V_PRIV_APPS=$(prefix_match "vendor/priv-app/" "$PACKAGES")
  if [ ! -z "$V_PRIV_APPS" ]; then
    write_packages "APPS" "true" "true" "none" "$V_PRIV_APPS" >> "$ANDROIDMK"
  fi

  # Framework
  local FRAMEWORK=$(prefix_match "framework/" "$PACKAGES")
  if [ ! -z "$FRAMEWORK" ]; then
    write_packages "JAVA_LIBRARIES" "false" "false" "none" "$FRAMEWORK" >> "$ANDROIDMK"
  fi

  # Etc
  local ETC=$(prefix_match "etc/" "$PACKAGES")
  if [ ! -z "$ETC" ]; then
    write_packages "ETC" "false" "false" "none" "$ETC" >> "$ANDROIDMK"
  fi
  local V_ETC=$(prefix_match "vendor/etc/" "$PACKAGES")
  if [ ! -z "$V_ETC" ]; then
    write_packages "ETC" "true" "false" "none" "$ETC" >> "$ANDROIDMK"
  fi

  # Executables
  local BIN=$(prefix_match "bin/" "$PACKAGES")
  if [ ! -z "$BIN" ]; then
    write_packages "EXECUTABLES" "false" "false" "none" "$BIN" >> "$ANDROIDMK"
  fi
  local V_BIN=$(prefix_match "vendor/bin/" "$PACKAGES")
  if [ ! -z "$V_BIN" ]; then
    write_packages "EXECUTABLES" "true" "false" "none" "$V_BIN" >> "$ANDROIDMK"
  fi

  echo "PRODUCT_PACKAGES += \\" >> "$PRODUCTMK"
  printf '    %s \\\n' "${PACKAGE_LIST[@]}" >> "$PRODUCTMK"
}

function write_header() {
YEAR=$(date +"%Y")

mkdir -p $(dirname "$1")

cat << EOF > $1
# Copyright (C) $YEAR The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is generated by device/$VENDOR/$DEVICE/setup-makefiles.sh

EOF
}

function extract() {
    local FILELIST=( $(egrep -v '(^-|^#|^[[:space:]]*$)' "$1" | sort | uniq) )
    local OLDIFS=
    local FILE=
    local DEST=
    local PARSING_ARRAY=
    local SRC="$2"
    local OUTPUT_DIR="$3"

    for FILE in "${FILELIST[@]}"; do
        OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
        FILE=$(echo "${PARSING_ARRAY[0]}" | sed -e "s/^-//g")
        local DEST="${PARSING_ARRAY[1]}"
        if [ -z "$DEST" ]; then
            DEST="$FILE"
        fi
        echo "Extracting /system/$FILE ..."
        local DIR=$(dirname "$FILE")
        if [ ! -d "$OUTPUT_DIR/$DIR" ]; then
            mkdir -p "$OUTPUT_DIR/$DIR"
        fi
        if [ "$SRC" = "adb" ]; then
            # Try CM target first
            adb pull "/system/$DEST" "$OUTPUT_DIR/$DEST"
            # if file does not exist try OEM target
            if [ "$?" != "0" ]; then
                adb pull "/system/$FILE" "$OUTPUT_DIR/$DEST"
            fi
        else
            cp "$SRC/system/$FILE" "$OUTPUT_DIR/$DEST"
            # if file dot not exist try destination
            if [ "$?" != "0" ]; then
                cp "$SRC/system/$DEST" "$OUTPUT_DIR/$DEST"
            fi
        fi
    done
}
