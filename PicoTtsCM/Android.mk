# SVOX Pico TTS Engine
# This makefile builds both an activity and a shared library.
LOCAL_PATH := $(call my-dir)

LOCAL_PICO_PATH := $(LOCAL_PATH)/../../external/svox/pico
include $(CLEAR_VARS)
LOCAL_PACKAGE_NAME := PicoTtsCM
LOCAL_PRIVILEGED_MODULE := true

LOCAL_OVERRIDES_PACKAGES := PicoTts

LOCAL_SRC_FILES := \
    $(call all-java-files-under, $(LOCAL_PICO_PATH)/src) \
    $(call all-java-files-under, $(LOCAL_PICO_PATH)/compat)
LOCAL_JNI_SHARED_LIBRARIES := libttscompat libttspico
LOCAL_PROGUARD_FLAG_FILES := proguard.flags
include $(BUILD_PACKAGE)
include $(LOCAL_PICO_PATH)/compat/jni/Android.mk \
    $(LOCAL_PICO_PATH)/lib/Android.mk \
    $(LOCAL_PICO_PATH)/tts/Android.mk
