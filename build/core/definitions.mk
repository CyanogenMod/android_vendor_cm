#
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
#

#
# Extra build definitions, sourced from $(TOP)/build/core/definitions.mk.
#
# Shared library caching
# ----------------------
#
# To enable, set USE_PREBUILT_CACHE=1 prior to starting a build.  The
# default cache location is $(TOP)/.cache.  This may be overridden with
# PREBUILT_CACHE_DIR.
#
# The main Android build system calls several "hooks" to allow vendors to
# implement extra functionality.  Among these are hooks intended to allow
# shared library caching.  These work by calling host-shared-library-hook
# and target-shared-library-hook, if they exist.  These are called once
# per shared library module, for both host and target shared libraries.
#
# If a shared library is cached, the hook sets LOCAL_PREBUILT_MODULE_FILE
# to the path of the cached file and it is treated as a prebuilt.  We call
# out to a script named shlib-cache-check with all the information needed
# to determine whether the shared library is cached and up to date.  Also
# note that the main build system will not populate headers nor symbol
# files (for target shared libraries), so we must do that here.
#
# If a shared library is not cached, the hook is responsible for adding
# any rules necessary to cache it for future use.  We add rules to call
# out to a script named shlib-cache-enter with all of the information
# needed for future calls to shlib-cache-check.
#

########################################
# base rules
########################################

ifeq ($(USE_PREBUILT_CACHE),1)
PREBUILT_CACHE_DIR ?= $(ANDROID_BUILD_TOP)/.cache
endif

define shell-escape
$(subst ",,$(subst \",,$1))
endef

########################################
# host shared library caching
########################################

ifeq ($(USE_PREBUILT_CACHE),1)

define host-cache-check
$(eval PREBUILT_CACHE_HIT := $(shell vendor/cm/tools/shlib-cache-check \
		"$(MODULE_CACHE_PATH)" \
		"$(LOCAL_PATH)" \
		"LOCAL_CC=$(LOCAL_CC)" \
		"LOCAL_CXX=$(LOCAL_CXX)" \
		"LOCAL_CFLAGS=$(call shell-escape,$(LOCAL_CFLAGS))" \
		"LOCAL_CPPFLAGS=$(call shell-escape,$(LOCAL_CPPFLAGS))" \
		"LOCAL_CPP_EXTENSION=$(LOCAL_CPP_EXTENSION)" \
		"HOST_GLOBAL_LD_DIRS=$(HOST_GLOBAL_LD_DIRS)" \
		"HOST_GLOBAL_LDFLAGS=$(HOST_GLOBAL_LDFLAGS)" \
		"LOCAL_SRC_FILES=$(strip $(LOCAL_SRC_FILES))")) \
$(info H: LOCAL_MODULE=$(LOCAL_MODULE) PREBUILT_CACHE_HIT=$(PREBUILT_CACHE_HIT)) \
$(if $(subst true,,$(PREBUILT_CACHE_HIT)),,$(MODULE_CACHE_PATH)/lib.so)
endef

define host-cache-miss
$(__INSTALLED_MODULE): $(MODULE_CACHE_PATH)/lib.so
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_MODULE_CACHE_PATH := $(MODULE_CACHE_PATH)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_LOCAL_PATH := $(LOCAL_PATH)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_INTERMEDIATES_PATH := $(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CC := $(LOCAL_CC)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CXX := $(LOCAL_CXX)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CFLAGS := $(call shell-escape,$(LOCAL_CFLAGS))
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CPPFLAGS := $(call shell-escape,$(LOCAL_CPPFLAGS))
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CPP_EXTENSION := $(LOCAL_CPP_EXTENSION)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_GLOBAL_LD_DIRS := $(HOST_GLOBAL_LD_DIRS)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_GLOBAL_LDFLAGS := $(HOST_GLOBAL_LDFLAGS)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_SRC_FILES := $(strip $(LOCAL_SRC_FILES))
$(MODULE_CACHE_PATH)/lib.so: $(__BUILT_MODULE) | $(ACP)
	@mkdir -p $$(@D)
	$(hide) $(ACP) $$^ $$@
	$(hide) vendor/cm/tools/shlib-cache-enter \
		"$$(PRIVATE_MODULE_CACHE_PATH)" \
		"$$(PRIVATE_LOCAL_PATH)" \
		"$$(PRIVATE_INTERMEDIATES_PATH)" \
		"LOCAL_CC=$$(PRIVATE_CC)" \
		"LOCAL_CXX=$$(PRIVATE_CXX)" \
		"LOCAL_CFLAGS=$$(PRIVATE_CFLAGS)" \
		"LOCAL_CPPFLAGS=$$(PRIVATE_CPPFLAGS)" \
		"LOCAL_CPP_EXTENSION=$$(PRIVATE_CPP_EXTENSION)" \
		"HOST_GLOBAL_LD_DIRS=$$(PRIVATE_GLOBAL_LD_DIRS)" \
		"HOST_GLOBAL_LDFLAGS=$$(PRIVATE_GLOBAL_LDFLAGS)" \
		"LOCAL_SRC_FILES=$$(PRIVATE_SRC_FILES)"
endef

define host-cache-hit
include $(BUILD_COPY_HEADERS)
endef

define host-shared-library-hook
$(eval MODULE_ARCH := $(HOST_$(LOCAL_2ND_ARCH_VAR_PREFIX)ARCH)) \
$(eval MODULE_CACHE_PATH := $(PREBUILT_CACHE_DIR)/host/SHARED_LIBRARIES/$(MODULE_ARCH)/$(LOCAL_MODULE)) \
$(eval __MODULE_FILE := $(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)) \
$(eval __INSTALLED_MODULE_PATH := $($(LOCAL_2ND_ARCH_VAR_PREFIX)HOST_OUT_$(LOCAL_MODULE_CLASS))) \
$(eval __INSTALLED_MODULE := $(__INSTALLED_MODULE_PATH)/$(__MODULE_FILE)) \
$(eval __BUILT_MODULE_PATH := $($(LOCAL_2ND_ARCH_VAR_PREFIX)HOST_OUT_INTERMEDIATE_LIBRARIES)) \
$(eval __BUILT_MODULE := $(__BUILT_MODULE_PATH)/$(__MODULE_FILE)) \
$(eval LOCAL_PREBUILT_MODULE_FILE := $(call host-cache-check)) \
$(eval $(if $(LOCAL_PREBUILT_MODULE_FILE),$(call host-cache-hit),$(call host-cache-miss)))
endef

endif # USE_PREBUILT_CACHE

########################################
# target shared library caching
########################################

ifeq ($(USE_PREBUILT_CACHE),1)

define target-cache-check
$(eval PREBUILT_CACHE_HIT := $(shell vendor/cm/tools/shlib-cache-check \
		"$(MODULE_CACHE_PATH)" \
		"$(LOCAL_PATH)" \
		"LOCAL_CC=$(LOCAL_CC)" \
		"LOCAL_CXX=$(LOCAL_CXX)" \
		"LOCAL_CFLAGS=$(call shell-escape,$(LOCAL_CFLAGS))" \
		"LOCAL_CPPFLAGS=$(call shell-escape,$(LOCAL_CPPFLAGS))" \
		"LOCAL_CPP_EXTENSION=$(LOCAL_CPP_EXTENSION)" \
		"TARGET_GLOBAL_LD_DIRS=$(TARGET_GLOBAL_LD_DIRS)" \
		"TARGET_GLOBAL_LDFLAGS=$(TARGET_GLOBAL_LDFLAGS)" \
		"LOCAL_SRC_FILES=$(strip $(LOCAL_SRC_FILES))")) \
$(info T: LOCAL_MODULE=$(LOCAL_MODULE) PREBUILT_CACHE_HIT=$(PREBUILT_CACHE_HIT)) \
$(if $(subst true,,$(PREBUILT_CACHE_HIT)),,$(MODULE_CACHE_PATH)/lib.so)
endef

define target-cache-miss
$(__INSTALLED_MODULE): $(MODULE_CACHE_PATH)/lib.so
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_MODULE_CACHE_PATH := $(MODULE_CACHE_PATH)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_BUILT_MODULE := $(__BUILT_MODULE)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_LINKED_MODULE := $(__LINKED_MODULE)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_LOCAL_PATH := $(LOCAL_PATH)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_INTERMEDIATES_PATH := $(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CC := $(LOCAL_CC)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CXX := $(LOCAL_CXX)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CFLAGS := $(call shell-escape,$(LOCAL_CFLAGS))
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CPPFLAGS := $(call shell-escape,$(LOCAL_CPPFLAGS))
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_CPP_EXTENSION := $(LOCAL_CPP_EXTENSION)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_TARGET_GLOBAL_LD_DIRS := $(TARGET_GLOBAL_LD_DIRS)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_TARGET_GLOBAL_LDFLAGS := $(TARGET_GLOBAL_LDFLAGS)
$(MODULE_CACHE_PATH)/lib.so: PRIVATE_SRC_FILES := $(strip $(LOCAL_SRC_FILES))
$(MODULE_CACHE_PATH)/lib.so: $(__LINKED_MODULE)
$(MODULE_CACHE_PATH)/lib.so: $(__BUILT_MODULE) | $(ACP)
	@mkdir -p $$(PRIVATE_MODULE_CACHE_PATH)
	$$(hide) $(ACP) $$(PRIVATE_BUILT_MODULE) $$(PRIVATE_MODULE_CACHE_PATH)/lib.so
	$$(hide) $(ACP) $$(PRIVATE_LINKED_MODULE) $$(PRIVATE_MODULE_CACHE_PATH)/symbols.so
	$$(hide) vendor/cm/tools/shlib-cache-enter \
		"$$(PRIVATE_MODULE_CACHE_PATH)" \
		"$$(PRIVATE_LOCAL_PATH)" \
		"$$(PRIVATE_INTERMEDIATES_PATH)" \
		"LOCAL_CC=$$(PRIVATE_CC)" \
		"LOCAL_CXX=$$(PRIVATE_CXX)" \
		"LOCAL_CFLAGS=$$(PRIVATE_CFLAGS)" \
		"LOCAL_CPPFLAGS=$$(PRIVATE_CPPFLAGS)" \
		"LOCAL_CPP_EXTENSION=$$(PRIVATE_CPP_EXTENSION)" \
		"TARGET_GLOBAL_LD_DIRS=$$(PRIVATE_TARGET_GLOBAL_LD_DIRS)" \
		"TARGET_GLOBAL_LDFLAGS=$$(PRIVATE_TARGET_GLOBAL_LDFLAGS)" \
		"LOCAL_SRC_FILES=$$(PRIVATE_SRC_FILES)"
endef

define target-cache-hit
include $(BUILD_COPY_HEADERS)
$(__INSTALLED_MODULE): $(__SYMBOLS_MODULE)
$(__SYMBOLS_MODULE): $(MODULE_CACHE_PATH)/symbols.so | $(ACP)
	@mkdir -p $$(@D)
	$$(hide) $(ACP) $$^ $$@
endef

define target-shared-library-hook
$(eval MODULE_ARCH := $(TARGET_$(LOCAL_2ND_ARCH_VAR_PREFIX)ARCH)) \
$(eval MODULE_CACHE_PATH := $(PREBUILT_CACHE_DIR)/target/$(TARGET_DEVICE)/SHARED_LIBRARIES/$(MODULE_ARCH)/$(LOCAL_MODULE)) \
$(eval __MODULE_FILE := $(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)) \
$(eval __INSTALLED_MODULE_PATH := $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET_OUT_$(LOCAL_MODULE_CLASS))) \
$(eval __INSTALLED_MODULE := $(__INSTALLED_MODULE_PATH)/$(__MODULE_FILE)) \
$(eval __BUILT_MODULE_PATH := $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET_OUT_INTERMEDIATE_LIBRARIES)) \
$(eval __BUILT_MODULE := $(__BUILT_MODULE_PATH)/$(__MODULE_FILE)) \
$(eval __LINKED_MODULE_PATH := $(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))/LINKED) \
$(eval __LINKED_MODULE := $(__LINKED_MODULE_PATH)/$(__MODULE_FILE)) \
$(eval __SYMBOLS_MODULE := $(TARGET_OUT_UNSTRIPPED)/$(patsubst $(PRODUCT_OUT)/%,%,$(__INSTALLED_MODULE))) \
$(eval LOCAL_PREBUILT_MODULE_FILE := $(call target-cache-check)) \
$(eval $(if $(LOCAL_PREBUILT_MODULE_FILE),$(call target-cache-hit),$(call target-cache-miss)))
endef

endif # USE_PREBUILT_CACHE
