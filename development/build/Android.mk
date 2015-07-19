# Copyright (C) 2015 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := $(call my-dir)

# ===== SDK jar file of stubs =====
# A.k.a the "current" version of the public SDK (cyanogenmod.jar inside the SDK package).
sdk_stub_name := cmsdk_stubs_current
stub_timestamp := $(OUT_DOCS)/cm-api-stubs-timestamp
include $(LOCAL_PATH)/build_cm_stubs.mk

.PHONY: cyanogenmod_stubs
cyanogenmod_stubs: $(full_target)

# The real rules create a javalib.jar that contains a classes.dex file.  This
# code is never going to be run anywhere, so just make a copy of the file.
# The package installation stuff doesn't know about this file, so nobody will
# ever be able to write a rule that installs it to a device.
$(dir $(full_target))javalib.jar: $(full_target)
	$(hide)$(ACP) $< $@

# cyanogenmod.jar is what we put in the SDK package.
cyanogenmod_jar_intermediates := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/cyanogenmod_jar_intermediates
cyanogenmod_jar_full_target := $(cyanogenmod_jar_intermediates)/cyanogenmod.jar

$(android_jar_full_target): $(full_target)
	@echo Package SDK Stubs: $@
	$(hide)mkdir -p $(dir $@)
	$(hide)$(ACP) $< $@

ALL_SDK_FILES += $(cyanogenmod_jar_full_target)

# ====================================================

# $(1): the Java library name
define _package_sdk_library
$(eval _psm_build_module := $(TARGET_OUT_COMMON_INTERMEDIATES)/JAVA_LIBRARIES/$(1)_intermediates/javalib.jar)
$(eval _psm_packaging_target := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/$(1)_intermediates/$(1).jar)
$(_psm_packaging_target) : $(_psm_build_module) | $(ACP)
	@echo "Package $(1).jar: $$@"
	$(hide) mkdir -p $$(dir $$@)
	$(hide) $(ACP) $$< $$@

ALL_SDK_FILES += $(_psm_packaging_target)
$(eval _psm_build_module :=)
$(eval _psm_packaging_target :=)
endef

# ============ System SDK ============
sdk_stub_name := cmsdk_system_stubs_current
stub_timestamp := $(OUT_DOCS)/cm-system-api-stubs-timestamp
include $(LOCAL_PATH)/build_cm_stubs.mk

.PHONY: cyanogenmod_system_stubs
cyanogenmod_system_stubs: $(full_target)

# Build and store the cyanogenmod_system.jar.
$(call dist-for-goals,sdk win_sdk,$(full_target):cyanogenmod_system.jar)
