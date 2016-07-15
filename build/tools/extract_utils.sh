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

PACKAGE_LIST=()
VENDOR_STATE=-1
COMMON=-1

#
# setup_vendor
#
# $1: device name
# $2: vendor name
# $3: output directory
# $4: common device - optional, default to false
# $5: cleanup - optional, default to true
#
# Must be called before any other functions can be used. This
# sets up the internal state for a new vendor configuration.
#
function setup_vendor() {
  export DEVICE="$1"
  if [ -z "$DEVICE" ]; then
    echo "\$DEVICE must be set before including this script!"
    exit 1
  fi

  export VENDOR="$2"
  if [ -z "$VENDOR" ]; then
    echo "\$VENDOR must be set before including this script!"
    exit 1
  fi

  export CM_ROOT="$3"
  if [ ! -d "$CM_ROOT" ]; then
    echo "\$CM_ROOT must be set and valid before including this script!"
    exit 1
  fi

  export OUTDIR=vendor/"$VENDOR"/"$DEVICE"
  if [ ! -d "$CM_ROOT/$OUTDIR" ]; then
    echo "$CM_ROOT/$OUTDIR does not exist!"
    exit 1
  fi

  export PRODUCTMK="$CM_ROOT"/"$OUTDIR"/"$DEVICE"-vendor.mk
  export ANDROIDMK="$CM_ROOT"/"$OUTDIR"/Android.mk
  export BOARDMK="$CM_ROOT"/"$OUTDIR"/BoardConfigVendor.mk

  if [ "$4" == "true" ] || [ "$4" == "1" ]; then
    COMMON=1
  else
    COMMON=0
  fi

  if [ "$5" == "true" ] || [ "$5" == "1" ]; then
    VENDOR_STATE=1
  else
    VENDOR_STATE=0
  fi
}

#
# prefix_match:
#
# $1: the prefix to match on
# $2*: list of files to inspect
#
# Internal function which loops thru the list and returns a new
# list containing the list of matched files with the matched
# prefix stripped away.
#
function prefix_match() {
    local prefix=$1
    shift
    local ary=( $@ )
    printf '%s\n' "${ary[@]}" | egrep "^$prefix" | sed -e "s#^$prefix##g"
}

#
# write_product_copy_files:
#
# $1: the file containing a list of blobs to copy
#
# Creates the PRODUCT_COPY_FILES section in the product makefile for all
# items in the list which do not start with a dash (-).
#
function write_product_copy_files() {
    local FILELIST=( $(egrep -v '(^-|^#|^[[:space:]]*$)' "$1" | sort | uniq) )
    local COUNT=${#FILELIST[@]}

    if [ "$COUNT" -eq "0" ]; then
        return 0
    fi

    printf '%s\n' "PRODUCT_COPY_FILES += \\" >> "$PRODUCTMK"
    for (( i=1; i<COUNT+1; i++ )); do
      local FILE="${FILELIST[$i-1]}"
      local LINEEND=" \\"
      if [ "$i" -eq "$COUNT" ]; then
        LINEEND=""
      fi

      # Split the file from the destination (format is "file[:destination]")
      local PARSING_ARRAY=(${FILE//:/ })
      if [ "${#PARSING_ARRAY[@]}" -eq "0" ]; then continue; fi
      local TARGET="${PARSING_ARRAY[0]}"
      local DEST="${PARSING_ARRAY[1]}"
      if [ -n "$DEST" ]; then
          TARGET=$DEST
      fi
      printf '    %s/proprietary/%s:system/%s%s\n' \
          "$OUTDIR" "$TARGET" "$TARGET" "$LINEEND" >> "$PRODUCTMK"
    done
    return 0
}

#
# write_packages:
#
# $1: The LOCAL_MODULE_CLASS for the given module list
# $2: "true" if this package is part of the vendor/ path
# $3: "true" if this is a privileged module (only valid for APPS)
# $4: The multilib mode, "32", "64", "both", or "none"
# $5*: The list of sanitized files under system/
#
# Internal function which writes out the BUILD_PREBUILT stanzas
# for all modules in the list. This is called by write_product_packages
# after the modules are categorized.
#
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

#
# write_product_packages:
#
# $1: file containing the list of blobs
#
# This function will create BUILD_PREBUILT entries in the
# Android.mk and associated PRODUCT_PACKAGES list in the
# product makefile for all files in the blob list which
# start with a single dash (-) character.
#
function write_product_packages() {
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

  # Actually write out the final PRODUCT_PACKAGES list
  local PACKAGE_COUNT=${#PACKAGE_LIST[@]}

  if [ "$PACKAGE_COUNT" = "0" ]; then
      return 0
  fi

  printf '\n%s\n' "PRODUCT_PACKAGES += \\" >> "$PRODUCTMK"
  for (( i=1; i<PACKAGE_COUNT+1; i++ )); do
    local LINEEND=" \\"
    if [ "$i" -eq "$PACKAGE_COUNT" ]; then
      LINEEND=""
    fi
    printf '    %s%s\n' "${PACKAGE_LIST[$i-1]}" "$LINEEND" >> "$PRODUCTMK"
  done
}

#
# write_header:
#
# $1: file which will be written to
#
# writes out the copyright header with the current year.
# note that this is not an append operation, and should
# be executed first!
#
function write_header() {
YEAR=$(date +"%Y")

mkdir -p "$(dirname "$1")"

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

#
# write_makefiles:
#
# $1: file containing the list of items to extract
#
# Calls write_product_copy_files and write_product_packages on
# the given file and appends to the Android.mk as well as
# the product makefile.
#
function write_makefiles() {
  write_product_copy_files "$1"
  write_product_packages "$1"
}

#
# write_headers:
#
# Calls write_header for each of the makefiles and creates
# the initial path declaration and device guard for the
# Android.mk
#
function write_headers() {
  write_header "$ANDROIDMK"
  cat << EOF >> "$ANDROIDMK"
LOCAL_PATH := \$(call my-dir)

EOF
  if [ "$COMMON" -ne 1 ]; then
    cat << EOF >> "$ANDROIDMK"
ifeq (\$(TARGET_DEVICE),$DEVICE)

EOF
  fi

  write_header "$BOARDMK"
  write_header "$PRODUCTMK"
}

#
# write_footers:
#
# Closes the inital guard and any other finalization tasks. Must
# be called as the final step.
#
function write_footers() {
cat << EOF >> "$ANDROIDMK"
endif
EOF
}

# Return success if adb is up and not in recovery
function _adb_connected {
    {
        if [[ "$(adb get-state)" == device &&
              "$(adb shell test -e /sbin/recovery; echo $?)" == 0 ]]
        then
            return 0
        fi
    } 2>/dev/null

    return 1
};

#
# extract:
#
# $1: file containing the list of items to extract
# $2: path to extracted system folder, or "adb" to extract from device
#
function extract() {
    adb start-server # Prevent unexpected starting server message from adb get-state in the next line
    if ! _adb_connected; then
        echo "No device is online. Waiting for one..."
        echo "Please connect USB and/or enable USB debugging"
        until _adb_connected; do
            sleep 1
        done
        echo "Device Found."
    fi

    # retrieve IP and PORT info if we're using a TCP connection
    TCPIPPORT=$(adb devices | egrep '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+[^0-9]+' \
        | head -1 | awk '{print $1}')
    adb root &> /dev/null
    sleep 0.3
    if [ -n "$TCPIPPORT" ]
    then
        # adb root just killed our connection
        # so reconnect...
        adb connect "$TCPIPPORT"
    fi
    adb wait-for-device &> /dev/null
    sleep 0.3

    if [ ! -e "$1" ]; then
      echo "$1 does not exist!"
      exit 1
    fi

    if [ -z "$OUTDIR" ]; then
      echo "Output dir not set!"
      exit 1
    fi

    local FILELIST=( $(egrep -v '(^#|^[[:space:]]*$)' "$1" | sort | uniq) )
    local COUNT=${#FILELIST[@]}
    local FILE=
    local DEST=
    local PARSING_ARRAY=
    local SRC="$2"
    local OUTPUT_DIR="$CM_ROOT"/"$OUTDIR"/proprietary

    if [ "$VENDOR_STATE" -eq "0" ]; then
      echo "Cleaning output directory ($OUTPUT_DIR).."
      rm -rf "${OUTPUT_DIR:?}/"*
      VENDOR_STATE=1
    fi

    echo "Extracting $COUNT files in $1 from $SRC:"

    for (( i=1; i<COUNT+1; i++ )); do
        local SPLIT=(${FILELIST[$i-1]//:/ })
        local FILE="${SPLIT[0]#-}"
        local DEST="${SPLIT[1]}"
        if [ -z "$DEST" ]; then
            DEST="$FILE"
        fi
        printf '  - %s .. ' "/system/$FILE"
        local DIR=$(dirname "$DEST")
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
                echo ""
            fi
        fi
        chmod 644 "$OUTPUT_DIR/$DEST"
    done
}
