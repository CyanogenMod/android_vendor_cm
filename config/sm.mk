# Written for SaberMod toolchains
# Find host os

# Set GCC colors
export GCC_COLORS := 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

UNAME := $(shell uname -s)

ifeq (Linux,$(UNAME))
  HOST_OS := linux
endif

# Only use these compilers on linux host.
ifeq (linux,$(HOST_OS))

#tobitege: check multiple versions
ifeq (1,$(words $(filter 4.8 4.8-sm 4.9 4.9-sm,$(TARGET_TC_ROM))))
USE_SM_TOOLCHAIN := true
endif

# Add extra libs for the compilers to use
# Filter by TARGET_ARCH since we're pointing to ARCH specific compilers.
# To use this on new devices define TARGET_ARCH in device makefile.
ifeq (arm,$(TARGET_ARCH))
ifeq (true,$(USE_SM_TOOLCHAIN))
export LD_LIBRARY_PATH := $(ANDROID_BUILD_TOP)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_TC_ROM)/arch-arm/usr/lib
export LIBRARY_PATH := $(ANDROID_BUILD_TOP)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_TC_ROM)/arch-arm/usr/lib
endif

# Path to toolchain
SM_AND_PATH := prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_TC_ROM)
SM_AND := $(shell $(SM_AND_PATH)/bin/arm-linux-androideabi-gcc --version)

# Find strings in version info
ifneq ($(filter (SaberMod%),$(SM_AND)),)
SM_AND_VERSION := $(filter 4.8.4 4.8.5 4.8.6 4.9.1 4.9.2 4.9.3 4.9.4,$(SM_AND))
SM_AND_NAME := $(filter (SaberMod%),$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_NAME)-$(SM_AND_DATE)-$(SM_AND_STATUS)
else
SM_AND_VERSION := $(filter 4.7 4.8 4.9 4.9.x%,$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_DATE)-$(SM_AND_STATUS)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sm.android=$(SM_AND_VERSION)

SM_KERNEL_PATH := prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-$(TARGET_TC_KERNEL)
SM_KERNEL := $(shell $(SM_KERNEL_PATH)/bin/arm-eabi-gcc --version)

ifneq ($(filter (SaberMod%),$(SM_KERNEL)),)
SM_KERNEL_VERSION := $(filter 4.8.4 4.8.5 4.8.6 4.9.1 4.9.2 4.9.3 4.9.4,$(SM_KERNEL))
SM_KERNEL_NAME := $(filter (SaberMod%),$(SM_KERNEL))
SM_KERNEL_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_KERNEL))
SM_KERNEL_STATUS := $(filter (release) (prerelease) (experimental),$(SM_KERNEL))
SM_KERNEL_VERSION := $(SM_KERNEL_VERSION)-$(SM_KERNEL_NAME)-$(SM_KERNEL_DATE)-$(SM_KERNEL_STATUS)
else
SM_KERNEL_VERSION := $(filter 4.7 4.8 4.9 4.9.x%,$(SM_KERNEL))
SM_KERNEL_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_KERNEL))
SM_KERNEL_STATUS := $(filter (release) (prerelease) (experimental),$(SM_KERNEL))
SM_KERNEL_VERSION := $(SM_KERNEL_VERSION)-$(SM_KERNEL_DATE)-$(SM_KERNEL_STATUS)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sm.kernel=$(SM_KERNEL_VERSION)

ifeq (true,$(BLISS_GRAPHITE))
OPT1 := (graphite)
GRAPHITE_FLAGS := \
  -fgraphite \
  -fgraphite-identity \
  -floop-flatten \
  -floop-parallelize-all \
  -ftree-loop-linear \
  -floop-interchange \
  -floop-strip-mine \
  -floop-block
ifeq ($(strip $(BLISSIFY)),true)
  GRAPHITE_FLAGS += \
    -Wno-error=maybe-uninitialized
endif
endif
endif

ifeq (arm64,$(TARGET_ARCH))
ifeq (true,$(USE_SM_TOOLCHAIN))
export LD_LIBRARY_PATH := $(ANDROID_BUILD_TOP)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-$(TARGET_TC_ROM)/arch-arm64/usr/lib
export LIBRARY_PATH := $(ANDROID_BUILD_TOP)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-$(TARGET_TC_ROM)/arch-arm64/usr/lib
endif

# Path to toolchain
SM_AND_PATH := prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-$(TARGET_TC_ROM)
SM_AND := $(shell $(SM_AND_PATH)/bin/aarch64-linux-android-gcc --version)

# Find strings in version info
ifneq ($(filter (SaberMod%),$(SM_AND)),)
SM_AND_VERSION := $(filter 4.9.1 4.9.2 4.9.3 4.9.4,$(SM_AND))
SM_AND_NAME := $(filter (SaberMod%),$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_NAME)-$(SM_AND_DATE)-$(SM_AND_STATUS)
else
SM_AND_VERSION := $(filter 4.8 4.9,$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_DATE)-$(SM_AND_STATUS)
endif

#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.sm.android=$(SM_AND_VERSION)

ifeq (true,$(BLISS_GRAPHITE))
OPT1 := (graphite)
GRAPHITE_FLAGS := \
  -fgraphite \
  -fgraphite-identity \
  -floop-flatten \
  -floop-parallelize-all \
  -ftree-loop-linear \
  -floop-interchange \
  -floop-strip-mine \
  -floop-block
ifeq ($(strip $(BLISSIFY)),true)
  GRAPHITE_FLAGS += \
    -Wno-error=maybe-uninitialized
endif
endif
endif
endif

# Force disable some modules that are not compatible with graphite flags.
# Add more modules if needed for devices in BoardConfig.mk
# LOCAL_DISABLE_GRAPHITE +=
LOCAL_DISABLE_GRAPHITE := \
  libunwind \
  libFFTEm \
  libicui18n \
  libskia \
  libvpx \
  libmedia_jni \
  libjni_filtershow_filters \
  libstagefright_mp3dec \
  libart \
  libavcodec \
  libSR_Core \
  fio

ifeq (1,$(words $(filter 4.9 4.9-sm,$(TARGET_TC_ROM))))
  LOCAL_DISABLE_GRAPHITE += \
    libFraunhoferAAC
endif

ifeq (true,$(BLISS_STRICT))
OPT2 := (strict)
endif

ifeq (true,$(BLISS_O3))
OPT3 := (extreme)
endif

ifeq (true,$(BLISS_KRAIT))
OPT4 := (krait)
endif

GCC_OPTIMIZATION_LEVELS := $(OPT1)$(OPT2)$(OPT3)$(OPT4)
#ifneq (,$(GCC_OPTIMIZATION_LEVELS))
#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.sm.flags=$(GCC_OPTIMIZATION_LEVELS)
#endif
