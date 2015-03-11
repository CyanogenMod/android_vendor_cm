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

ifeq ($(strip $(TARGET_TC_ROM)),)
TARGET_TC_ROM :=4.8-sm
endif

#tobitege: check multiple versions
#ifeq (1,$(words $(filter 4.8 4.8-linaro 4.8-sm 4.9 4.9-linaro 4.9-sm,$(TARGET_TC_ROM))))
ifeq (1,$(words $(filter 4.8 4.8-% 4.9 4.9-%,$(TARGET_TC_ROM))))
USE_SM_TOOLCHAIN := true
ifeq ($(strip $(TARGET_TC_KERNEL)),)
TARGET_TC_KERNEL :=4.9-sm
endif
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
SM_AND_VERSION := $(filter 4.8.% 4.8-% 4.9-% 4.9.%,$(SM_AND))
SM_AND_NAME := $(filter (SaberMod%),$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_NAME)-$(SM_AND_DATE)-$(SM_AND_STATUS)
else
SM_AND_VERSION := $(filter 4.7 4.7.% 4.8 4.8-% 4.8.% 4.9 4.9-% 4.9.x%,$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_DATE)-$(SM_AND_STATUS)
endif

#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.sm.android=$(SM_AND_VERSION)

SM_KERNEL_PATH := prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-$(TARGET_TC_KERNEL)
SM_KERNEL := $(shell $(SM_KERNEL_PATH)/bin/arm-eabi-gcc --version)

ifneq ($(filter (SaberMod%),$(SM_KERNEL)),)
SM_KERNEL_VERSION := $(filter 4.7 4.7.% 4.8 4.8.% 4.9 4.9.%,$(SM_KERNEL))
SM_KERNEL_NAME := $(filter (SaberMod%),$(SM_KERNEL))
SM_KERNEL_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_KERNEL))
SM_KERNEL_STATUS := $(filter (release) (prerelease) (experimental),$(SM_KERNEL))
SM_KERNEL_VERSION := $(SM_KERNEL_VERSION)-$(SM_KERNEL_NAME)-$(SM_KERNEL_DATE)-$(SM_KERNEL_STATUS)
else
SM_KERNEL_VERSION := $(filter 4.7 4.7.% 4.8 4.8.% 4.9 4.9.x%,$(SM_KERNEL))
SM_KERNEL_NAME := $(filter (Linaro%),$(SM_KERNEL))
SM_KERNEL_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_KERNEL))
SM_KERNEL_STATUS := $(filter (release) (prerelease) (experimental),$(SM_KERNEL))
SM_KERNEL_VERSION := $(SM_KERNEL_VERSION)-$(SM_KERNEL_DATE)-$(SM_KERNEL_STATUS)
endif

#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.sm.kernel=$(SM_KERNEL_VERSION)

endif #arm==TARGET_ARCH

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
SM_AND_VERSION := $(filter 4.8.3 4.8.4 4.8.5 4.8.6 4.9.1 4.9.2 4.9.3 4.9.4,$(SM_AND))
SM_AND_NAME := $(filter (SaberMod%),$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_NAME)-$(SM_AND_DATE)-$(SM_AND_STATUS)
else
SM_AND_VERSION := $(filter 4.7 4.7.% 4.8 4.8.% 4.9 4.9.%,$(SM_AND))
SM_AND_DATE := $(filter 20140% 20141% 20150% 20151%,$(SM_AND))
SM_AND_STATUS := $(filter (release) (prerelease) (experimental),$(SM_AND))
SM_AND_VERSION := $(SM_AND_VERSION)-$(SM_AND_DATE)-$(SM_AND_STATUS)
endif

#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.sm.android=$(SM_AND_VERSION)

endif
endif #arm64==TARGET_ARCH

ifeq ($(strip $(BLISS_GRAPHITE)),true)
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

# Force disable some modules that are not compatible with graphite flags.
# Add more modules if needed for devices in BoardConfig.mk
# LOCAL_DISABLE_GRAPHITE +=
# Force disable some modules that are not compatible with graphite flags.
# Add more modules if needed for devices in BoardConfig.mk
# LOCAL_DISABLE_GRAPHITE +=
LOCAL_DISABLE_GRAPHITE := \
  libmincrypt \
  mkbootimg \
  mkbootfs \
  libhost \
  ibext2_profile \
  make_ext4fs \
  hprof-conv \
  acp \
  libsqlite \
  libsqlite_jni \
  simg2img_host \
  e2fsck \
  append2simg \
  build_verity_tree \
  sqlite3 \
  e2fsck_host \
  libext2_profile_host \
  libext2_quota_host \
  libext2fs_host\
  libbz\
  make_f2fs\
  imgdiff\
  bsdiff \
  libedify \
  fs_config \
  unpackbootimg \
  mkyaffs2image \
  libext2_com_err_host \
  libext2_blkid_host \
  libext2_e2p_host\
  libcrypto-host \
  libexpat-host \
  libicuuc-host \
  libicui18n-host \
  dmtracedump \
  libsparse_host \
  libz-host \
  libfdlibm \
  libsqlite3_android \
  libssl-host \
  libf2fs_dlutils_host \
  libf2fs_utils_host \
  libf2fs_ioutils_host \
  libf2fs_fmt_host_dyn \
  libext2_uuid_host \
  minigzip \
  libdex \
  dexdump \
  dexlist \
  libext4_utils_host \
  third_party_protobuf_protoc_arm_host_gyp \
  libaapt \
  aapt \
  fastboot  \
  libpng \
  aprotoc \
  fio \
  fsck.f2fs \
  libandroidfw \
  libbacktrace_test \
  liblog \
  libgtest_host \
  libbacktrace_libc++ \
  v8_tools_gyp_v8_nosnapshot_arm_host_gyp \
  third_party_icu_icui18n_arm_host_gyp \
  third_party_icu_icuuc_arm_host_gyp \
  tird_party_protobuf_protobuf_full_do_not_use_arm_host_gyp \
  third_party_protobuf_protobuf_full_do_not_use_arm_host_gyp \
  v8_tools_gyp_mksnapshot_arm_host_gyp \
  third_party_libvpx_libvpx_obj_int_extract_arm_host_gyp \
  libutils \
  libcutils \
  libexpat \
  v8_tools_gyp_v8_base_arm_host_gyp \
  v8_tools_gyp_v8_libbase_arm_host_gyp \
  v8_tools_gyp_v8_libbase_arm_host_gyp_32 \
  aidl \
  libziparchive-host \
  libcrypto_static \
  libunwind-ptrace \
  libgtest_main_host \
  libbacktrace \
  backtrace_test \
  libzopfli \
  zipalign \
  rsg-generator \
  unrar \
  libunz \
  adb \
  libzipfile \
  rsg-generator_support \
  libunwindbacktrace \
  libc_common \
  libz \
  libselinux \
  checkfc \
  checkseapp \
  checkpolicy \
  libsepol \
  libpcre \
  libunwind \
  libFFTEm \
  libicui18n \
  libskia \
  libvpx \
  libmedia_jni \
  libstagefright_mp3dec \
  libart \
  mdnsd \
  libwebrtc_spl \
  third_party_WebKit_Source_core_webcore_svg_gyp \
  libjni_filtershow_filters \
  libavformat \
  libavcodec \
  skia_skia_library_gyp

ifeq (1,$(words $(filter 4.9 4.9-sm,$(TARGET_TC_ROM))))
  LOCAL_DISABLE_GRAPHITE += \
    libFraunhoferAAC
endif

ifeq (true,$(BLISS_O3))
OPT3 := (O3)
endif

ifeq (true,$(BLISS_STRICT))
OPT2 := (strict)
endif

ifeq (true,$(BLISS_KRAIT))
OPT4 := (krait)
endif

GCC_OPTIMIZATION_LEVELS := $(OPT1)$(OPT2)$(OPT3)$(OPT4)
#ifneq (,$(GCC_OPTIMIZATION_LEVELS))
#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.sm.flags=$(GCC_OPTIMIZATION_LEVELS)
#endif
