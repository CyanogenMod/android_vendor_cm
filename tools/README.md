Universal extract-files scripts for Cyanogenmod
===============================

This is designed to automatically create all neccessary makefiles, including ones for prebuilt
apk's and libs.

See the extract-files.sh.template for an example of what should be in your device tree's
extract-files.sh

You will also need the following files to describe the props to be extracted.

All "prebuilt" files (apk's or lib's) must have a "-" in front of the name.

i.e. -vendor/lib/libtime_genoff.so

This will prevent them from going in the PRODUCT_COPY_FILES block and instead build a makefile to
build them as a prebuilt and include them in PRODUCT_PACKAGES.


In your device tree:
	device-proprietary-files.txt - Lists all device specific files

If you have a common device tree that shares props amoung your device family, you will need:
	common-proprietary-files.txt - Lists all common files that are shared in the device family

Optionally you can also have:
	proprietary-files.txt - Lists files that are on all devices but need to be device specific
