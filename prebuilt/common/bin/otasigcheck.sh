#!/sbin/sh

# Validate that the incoming OTA is compatible with an already-installed
# system

grep -q "Command:.*\"--wipe\_data\"" /tmp/recovery.log
if [ $? -eq 0 ]; then
  echo "Data will be wiped after install; skipping signature check..."
  exit 0
fi

grep -q "Command:.*\"--headless\"" /tmp/recovery.log
if [ $? -eq 0 ]; then
  echo "Headless mode install; skipping signature check..."
  exit 0
fi

if [ -f "/data/system/packages.xml" -a -f "/tmp/releasekey" ]; then
  relkey=$(cat "/tmp/releasekey")
  OLDIFS="$IFS"
  IFS=""
  while read line; do
    echo "$line" | grep -q "^ *<cert index=[^ ]* key="
    if [ $? -eq 0 ]; then
      idx=$(echo $line | grep -o "index=[^ ]*" | cut -d'=' -f2 | cut -d'"' -f2)
      key=$(echo $line | grep -o "key=[^ ]*" | cut -d'=' -f2 | cut -d'"' -f2)
      eval "key_$idx=$key"
      continue
    fi
    echo "$line" | grep -q "^ *<package name="
    if [ $? -eq 0 ]; then
      package=$(echo $line | grep -o "name=[^ ]*" | cut -d'=' -f2 | cut -d'"' -f2)
      continue
    fi
    if [ "$package" != "com.android.htmlviewer" ]; then
      continue
    fi
    echo $line | grep -q " *<cert index="
    if [ $? -eq 0 ]; then
      cert_idx=$(echo $line | grep -o "index=[^ ]*" | cut -d'=' -f2 | cut -d'"' -f2)
      break
    fi
  done < "/data/system/packages.xml"
  IFS="$OLDIFS"

  # Tools missing? Err on the side of caution and exit cleanly
  if [ -z "$cert_idx" ]; then
    echo "Package cert index not found; skipping signature check..."
    exit 0
  fi

  varname="key_$cert_idx"
  eval "pkgkey=\$$varname"

  if [ "$pkgkey" != "$relkey" ]; then
     echo "You have an installed system that isn't signed with this build's key, aborting..."
     exit 124
  fi
fi

exit 0
