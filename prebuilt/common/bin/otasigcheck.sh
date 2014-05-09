#!/sbin/sh

# Validate that the incoming OTA is compatible with an already-installed
# system

if [ -f /data/system/packages.xml -a -f /tmp/releasekey ]; then
  grep -q `cat /tmp/releasekey` /data/system/packages.xml
  if [ $? -ne 0 ]; then
     echo "You have an installed system that isn't signed with this build's key, aborting..."
     # Edify doesn't abort on non-zero executions, so let's trash the key and use sha1sum instead
     echo "INVALID" > /tmp/releasekey
     exit 1
  fi
fi

exit 0
