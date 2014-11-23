#!/sbin/sh
mkdir -p /tmp/supersu_1/
unzip -o -q /system/etc/supersu.zip -d /tmp/supersu_1/
chmod 755 /tmp/supersu_1/META-INF/com/google/android/update-binary
cp /system/etc/supersu.zip /tmp/supersu.zip
rm -rf /system/etc/supersu.zip
sh /tmp/supersu_1/META-INF/com/google/android/update-binary 2 20 /tmp/supersu.zip
