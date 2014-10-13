LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := Term.apk
LOCAL_MODULE_OWNER := cm
LOCAL_SRC_FILES := Term.apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS  := optional
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
include $(BUILD_PREBUILT)

$(LOCAL_PATH)/Term.apk:
	curl -L -o $@ -O -L https://jackpal.github.com/Android-Terminal-Emulator/downloads/Term.apk
	unzip -o -d $(dir $@) $@ lib/*

$(LOCAL_PATH)/lib/armeabi/libjackpal-androidterm4.so: $(LOCAL_PATH)/Term.apk

$(LOCAL_PATH)/lib/mips/libjackpal-androidterm4.so: $(LOCAL_PATH)/Term.apk

$(LOCAL_PATH)/lib/x86/libjackpal-androidterm4.so: $(LOCAL_PATH)/Term.apk
