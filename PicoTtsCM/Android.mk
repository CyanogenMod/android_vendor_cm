# SVOX Pico TTS Engine
# This makefile builds both an activity and a shared library.
LOCAL_PATH := $(LOCAL_PATH)/../../external/svox/pico
include $(CLEAR_VARS)
LOCAL_PACKAGE_NAME := PicoTtsCM
LOCAL_PRIVILEGED_MODULE := true

LOCAL_OVERRIDES_PACKAGES := PicoTts

LOCAL_SRC_FILES := \
    $(call all-java-files-under, src) \
    $(call all-java-files-under, compat)
LOCAL_JNI_SHARED_LIBRARIES := libttscompat libttspico
LOCAL_PROGUARD_FLAG_FILES := proguard.flags
include $(BUILD_PACKAGE)
include $(LOCAL_PATH)/compat/jni/Android.mk \
    $(LOCAL_PATH)/lib/Android.mk \
    $(LOCAL_PATH)/tts/Android.mk
