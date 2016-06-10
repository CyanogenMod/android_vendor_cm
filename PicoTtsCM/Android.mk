LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

pico_dir := ../../../external/svox/pico

LOCAL_PACKAGE_NAME := PicoTtsCM
LOCAL_PRIVILEGED_MODULE := true

LOCAL_OVERRIDES_PACKAGES := PicoTts

src_files := \
    $(pico_dir)/src \
    $(pico_dir)/compat

LOCAL_SRC_FILES := \
    $(call all-java-files-under, $(src_files))

LOCAL_RESOURCE_DIR := \
    $(LOCAL_PATH)/$(pico_dir)/res

LOCAL_MANIFEST_FILE := \
    $(pico_dir)/AndroidManifest.xml

LOCAL_JNI_SHARED_LIBRARIES := libttscompat libttspico

LOCAL_PROGUARD_FLAG_FILES := proguard.flags

include $(BUILD_PACKAGE)
