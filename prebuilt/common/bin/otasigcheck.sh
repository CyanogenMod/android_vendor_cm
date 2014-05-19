#!/sbin/sh

# Validate that the incoming OTA is compatible with an already-installed
# system

if [ -f /data/system/packages.xml -a -f /tmp/releasekey ]; then
  relCert=$(grep -A3 'package name="com.android.providers.calendar"' /data/system/packages.xml  | grep "cert index" | head -n 1 | sed -e 's|.*"\([[:digit:]]\)".*|\1|g')

  grep "cert index=\"$relCert\"" /data/system/packages.xml | grep -q `cat /tmp/releasekey`
  if [ $? -ne 0 ]; then
     echo "You have an installed system that isn't signed with this build's key, aborting..."
     # Edify doesn't abort on non-zero executions, so let's trash the key and use sha1sum instead
     echo "INVALID" > /tmp/releasekey
     exit 1
  fi
fi

exit 0
