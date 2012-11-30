PRODUCT_BRAND ?= cyanogenmod

# To deal with CM9 specifications
# TODO: remove once all devices have been switched
ifneq ($(TARGET_BOOTANIMATION_NAME),)
TARGET_SCREEN_DIMENSIONS := $(subst -, $(space), $(subst x, $(space), $(TARGET_BOOTANIMATION_NAME)))
ifeq ($(TARGET_SCREEN_WIDTH),)
TARGET_SCREEN_WIDTH := $(word 2, $(TARGET_SCREEN_DIMENSIONS))
endif
ifeq ($(TARGET_SCREEN_HEIGHT),)
TARGET_SCREEN_HEIGHT := $(word 3, $(TARGET_SCREEN_DIMENSIONS))
endif
endif

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# clear TARGET_BOOTANIMATION_NAME in case it was set for CM9 purposes
TARGET_BOOTANIMATION_NAME :=

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/cm/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

ifdef CM_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmodnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.google.clientidbase=android-google \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/cm/CHANGELOG.mkdn:system/etc/CHANGELOG-CM.txt

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/cm/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/cm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Compcache/Zram support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/compcache:system/bin/compcache \
    vendor/cm/prebuilt/common/bin/handle_compcache:system/bin/handle_compcache

# Nam configuration script
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/modelid_cfg.sh:system/bin/modelid_cfg.sh

PRODUCT_COPY_FILES +=  \
    vendor/cm/proprietary/Term.apk:system/app/Term.apk \
    vendor/cm/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/cm/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/cm/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/mkshrc:system/etc/mkshrc

# T-Mobile theme engine
include vendor/cm/config/themes_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    Camera \
    Development \
    LatinIME \
    SpareParts \
    Superuser \
    su

# Optional CM packages
PRODUCT_PACKAGES += \
    VideoEditor \
    VoiceDialer \
    SoundRecorder \
    Basic

# Custom CM packages
PRODUCT_PACKAGES += \
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    CMWallpapers \
    Apollo \
    CMUpdater \
    CMFileManager

# Extra tools in CM
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    vim \
    nano \
    htop \
    powertop \
    lsof

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/common

PRODUCT_VERSION_MAJOR = 10
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0

# Set CM_BUILDTYPE
ifdef CM_NIGHTLY
    CM_BUILDTYPE := NIGHTLY
endif
ifdef CM_EXPERIMENTAL
    CM_BUILDTYPE := EXPERIMENTAL
endif
ifdef CM_RELEASE
    CM_BUILDTYPE := RELEASE
endif

ifdef CM_BUILDTYPE
    ifdef CM_EXTRAVERSION
        # Force build type to EXPERIMENTAL
        CM_BUILDTYPE := EXPERIMENTAL
        # Add leading dash to CM_EXTRAVERSION
        CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
    endif
else
    # If CM_BUILDTYPE is not defined, set to UNOFFICIAL
    CM_BUILDTYPE := UNOFFICIAL
    CM_EXTRAVERSION :=
endif

ifdef CM_RELEASE
    CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CM_BUILD)
else
    CM_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(CM_BUILDTYPE)-$(CM_BUILD)$(CM_EXTRAVERSION)
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.version=$(CM_VERSION) \
  ro.modversion=$(CM_VERSION)


-include $(WORKSPACE)/hudson/image-auto-bits.mk

#terminfo
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/terminfo/v/versaterm:system/etc/terminfo/v/versaterm \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt220-nam:system/etc/terminfo/v/vt220-nam \
    vendor/cm/prebuilt/common/etc/terminfo/v/vip:system/etc/terminfo/v/vip \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi200:system/etc/terminfo/v/vi200 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi550:system/etc/terminfo/v/vi550 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt102-w:system/etc/terminfo/v/vt102-w \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320-w-nam:system/etc/terminfo/v/vt320-w-nam \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-nav:system/etc/terminfo/v/vt100-nav \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt420pc:system/etc/terminfo/v/vt420pc \
    vendor/cm/prebuilt/common/etc/terminfo/v/vip-Hw:system/etc/terminfo/v/vip-Hw \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi50adm:system/etc/terminfo/v/vi50adm \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi200-rv:system/etc/terminfo/v/vi200-rv \
    vendor/cm/prebuilt/common/etc/terminfo/v/vremote:system/etc/terminfo/v/vremote \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi300-old:system/etc/terminfo/v/vi300-old \
    vendor/cm/prebuilt/common/etc/terminfo/v/vc303a:system/etc/terminfo/v/vc303a \
    vendor/cm/prebuilt/common/etc/terminfo/v/vip-w:system/etc/terminfo/v/vip-w \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt340:system/etc/terminfo/v/vt340 \
    vendor/cm/prebuilt/common/etc/terminfo/v/v3220:system/etc/terminfo/v/v3220 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt400:system/etc/terminfo/v/vt400 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt200-js:system/etc/terminfo/v/vt200-js \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320-nam:system/etc/terminfo/v/vt320-nam \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi300:system/etc/terminfo/v/vi300 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-vb:system/etc/terminfo/v/vt100-vb \
    vendor/cm/prebuilt/common/etc/terminfo/v/vc404-s:system/etc/terminfo/v/vc404-s \
    vendor/cm/prebuilt/common/etc/terminfo/v/vc414:system/etc/terminfo/v/vc414 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt220d:system/etc/terminfo/v/vt220d \
    vendor/cm/prebuilt/common/etc/terminfo/v/vanilla:system/etc/terminfo/v/vanilla \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320-k3:system/etc/terminfo/v/vt320-k3 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi500:system/etc/terminfo/v/vi500 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320nam:system/etc/terminfo/v/vt320nam \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320:system/etc/terminfo/v/vt320 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt420pcdos:system/etc/terminfo/v/vt420pcdos \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt50h:system/etc/terminfo/v/vt50h \
    vendor/cm/prebuilt/common/etc/terminfo/v/vc303:system/etc/terminfo/v/vc303 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt220-8bit:system/etc/terminfo/v/vt220-8bit \
    vendor/cm/prebuilt/common/etc/terminfo/v/vp90:system/etc/terminfo/v/vp90 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt102:system/etc/terminfo/v/vt102 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt220-w:system/etc/terminfo/v/vt220-w \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-w:system/etc/terminfo/v/vt100-w \
    vendor/cm/prebuilt/common/etc/terminfo/v/vp60:system/etc/terminfo/v/vp60 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi50:system/etc/terminfo/v/vi50 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vip-H:system/etc/terminfo/v/vip-H \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-nav-w:system/etc/terminfo/v/vt100-nav-w \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi200-f:system/etc/terminfo/v/vi200-f \
    vendor/cm/prebuilt/common/etc/terminfo/v/viewpoint:system/etc/terminfo/v/viewpoint \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt125:system/etc/terminfo/v/vt125 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100nam:system/etc/terminfo/v/vt100nam \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-s-bot:system/etc/terminfo/v/vt100-s-bot \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt131:system/etc/terminfo/v/vt131 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi55:system/etc/terminfo/v/vi55 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt510pcdos:system/etc/terminfo/v/vt510pcdos \
    vendor/cm/prebuilt/common/etc/terminfo/v/vi603:system/etc/terminfo/v/vi603 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vc404:system/etc/terminfo/v/vc404 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt132:system/etc/terminfo/v/vt132 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt510:system/etc/terminfo/v/vt510 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vc415:system/etc/terminfo/v/vc415 \
    vendor/cm/prebuilt/common/etc/terminfo/v/visa50:system/etc/terminfo/v/visa50 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vp3a+:system/etc/terminfo/v/vp3a+ \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt50:system/etc/terminfo/v/vt50 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt420f:system/etc/terminfo/v/vt420f \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt520:system/etc/terminfo/v/vt520 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt510pc:system/etc/terminfo/v/vt510pc \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-w-nam:system/etc/terminfo/v/vt100-w-nam \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt220-old:system/etc/terminfo/v/vt220-old \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt220:system/etc/terminfo/v/vt220 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100-s:system/etc/terminfo/v/vt100-s \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt102-nsgr:system/etc/terminfo/v/vt102-nsgr \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320-w:system/etc/terminfo/v/vt320-w \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt320-k311:system/etc/terminfo/v/vt320-k311 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt61:system/etc/terminfo/v/vt61 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt52:system/etc/terminfo/v/vt52 \
    vendor/cm/prebuilt/common/etc/terminfo/v/v5410:system/etc/terminfo/v/v5410 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt525:system/etc/terminfo/v/vt525 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vsc:system/etc/terminfo/v/vsc \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt420:system/etc/terminfo/v/vt420 \
    vendor/cm/prebuilt/common/etc/terminfo/v/vt100:system/etc/terminfo/v/vt100 \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-koi8r:system/etc/terminfo/l/linux-koi8r \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-c-nc:system/etc/terminfo/l/linux-c-nc \
    vendor/cm/prebuilt/common/etc/terminfo/l/ln03-w:system/etc/terminfo/l/ln03-w \
    vendor/cm/prebuilt/common/etc/terminfo/l/liswb:system/etc/terminfo/l/liswb \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-c:system/etc/terminfo/l/linux-c \
    vendor/cm/prebuilt/common/etc/terminfo/l/luna:system/etc/terminfo/l/luna \
    vendor/cm/prebuilt/common/etc/terminfo/l/lisaterm:system/etc/terminfo/l/lisaterm \
    vendor/cm/prebuilt/common/etc/terminfo/l/lisaterm-w:system/etc/terminfo/l/lisaterm-w \
    vendor/cm/prebuilt/common/etc/terminfo/l/lisa:system/etc/terminfo/l/lisa \
    vendor/cm/prebuilt/common/etc/terminfo/l/lft:system/etc/terminfo/l/lft \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-m:system/etc/terminfo/l/linux-m \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-nic:system/etc/terminfo/l/linux-nic \
    vendor/cm/prebuilt/common/etc/terminfo/l/ln03:system/etc/terminfo/l/ln03 \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-koi8:system/etc/terminfo/l/linux-koi8 \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux:system/etc/terminfo/l/linux \
    vendor/cm/prebuilt/common/etc/terminfo/l/lpr:system/etc/terminfo/l/lpr \
    vendor/cm/prebuilt/common/etc/terminfo/l/linux-lat:system/etc/terminfo/l/linux-lat \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-76:system/etc/terminfo/g/guru-76 \
    vendor/cm/prebuilt/common/etc/terminfo/g/go140w:system/etc/terminfo/g/go140w \
    vendor/cm/prebuilt/common/etc/terminfo/g/graphos-30:system/etc/terminfo/g/graphos-30 \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-76-w:system/etc/terminfo/g/guru-76-w \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-s:system/etc/terminfo/g/guru-s \
    vendor/cm/prebuilt/common/etc/terminfo/g/go225:system/etc/terminfo/g/go225 \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-76-lp:system/etc/terminfo/g/guru-76-lp \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-76-s:system/etc/terminfo/g/guru-76-s \
    vendor/cm/prebuilt/common/etc/terminfo/g/gt42:system/etc/terminfo/g/gt42 \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-44-s:system/etc/terminfo/g/guru-44-s \
    vendor/cm/prebuilt/common/etc/terminfo/g/gator:system/etc/terminfo/g/gator \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-rv:system/etc/terminfo/g/guru-rv \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-44:system/etc/terminfo/g/guru-44 \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru:system/etc/terminfo/g/guru \
    vendor/cm/prebuilt/common/etc/terminfo/g/gator-52t:system/etc/terminfo/g/gator-52t \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru+rv:system/etc/terminfo/g/guru+rv \
    vendor/cm/prebuilt/common/etc/terminfo/g/gs6300:system/etc/terminfo/g/gs6300 \
    vendor/cm/prebuilt/common/etc/terminfo/g/gt40:system/etc/terminfo/g/gt40 \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-76-wm:system/etc/terminfo/g/guru-76-wm \
    vendor/cm/prebuilt/common/etc/terminfo/g/gigi:system/etc/terminfo/g/gigi \
    vendor/cm/prebuilt/common/etc/terminfo/g/gator-t:system/etc/terminfo/g/gator-t \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru+s:system/etc/terminfo/g/guru+s \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-nctxt:system/etc/terminfo/g/guru-nctxt \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-24:system/etc/terminfo/g/guru-24 \
    vendor/cm/prebuilt/common/etc/terminfo/g/go140:system/etc/terminfo/g/go140 \
    vendor/cm/prebuilt/common/etc/terminfo/g/glasstty:system/etc/terminfo/g/glasstty \
    vendor/cm/prebuilt/common/etc/terminfo/g/guru-76-w-s:system/etc/terminfo/g/guru-76-w-s \
    vendor/cm/prebuilt/common/etc/terminfo/g/gator-52:system/etc/terminfo/g/gator-52 \
    vendor/cm/prebuilt/common/etc/terminfo/g/graphos:system/etc/terminfo/g/graphos \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi955-hb:system/etc/terminfo/t/tvi955-hb \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4025-17:system/etc/terminfo/t/tek4025-17 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi950-rv:system/etc/terminfo/t/tvi950-rv \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti924-8:system/etc/terminfo/t/ti924-8 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tws-generic:system/etc/terminfo/t/tws-generic \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti916-8:system/etc/terminfo/t/ti916-8 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4113-nd:system/etc/terminfo/t/tek4113-nd \
    vendor/cm/prebuilt/common/etc/terminfo/t/t16:system/etc/terminfo/t/t16 \
    vendor/cm/prebuilt/common/etc/terminfo/t/t3800:system/etc/terminfo/t/t3800 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tab132-rv:system/etc/terminfo/t/tab132-rv \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4112-nd:system/etc/terminfo/t/tek4112-nd \
    vendor/cm/prebuilt/common/etc/terminfo/t/tws2103-sna:system/etc/terminfo/t/tws2103-sna \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti926:system/etc/terminfo/t/ti926 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4115:system/etc/terminfo/t/tek4115 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi921:system/etc/terminfo/t/tvi921 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi9065:system/etc/terminfo/t/tvi9065 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4404:system/etc/terminfo/t/tek4404 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4105a:system/etc/terminfo/t/tek4105a \
    vendor/cm/prebuilt/common/etc/terminfo/t/tab132:system/etc/terminfo/t/tab132 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4112-5:system/etc/terminfo/t/tek4112-5 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tty40:system/etc/terminfo/t/tty40 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4014:system/etc/terminfo/t/tek4014 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi912c:system/etc/terminfo/t/tvi912c \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4025a:system/etc/terminfo/t/tek4025a \
    vendor/cm/prebuilt/common/etc/terminfo/t/t1061:system/etc/terminfo/t/t1061 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4015-sm:system/etc/terminfo/t/tek4015-sm \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi920b:system/etc/terminfo/t/tvi920b \
    vendor/cm/prebuilt/common/etc/terminfo/t/tab132-w:system/etc/terminfo/t/tab132-w \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4015:system/etc/terminfo/t/tek4015 \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti700:system/etc/terminfo/t/ti700 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi950-rv-2p:system/etc/terminfo/t/tvi950-rv-2p \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti924:system/etc/terminfo/t/ti924 \
    vendor/cm/prebuilt/common/etc/terminfo/t/trs2:system/etc/terminfo/t/trs2 \
    vendor/cm/prebuilt/common/etc/terminfo/t/trs16:system/etc/terminfo/t/trs16 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4023:system/etc/terminfo/t/tek4023 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4014-sm:system/etc/terminfo/t/tek4014-sm \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4105-30:system/etc/terminfo/t/tek4105-30 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi955-w:system/etc/terminfo/t/tvi955-w \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4207-s:system/etc/terminfo/t/tek4207-s \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi970:system/etc/terminfo/t/tvi970 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tty33:system/etc/terminfo/t/tty33 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4106brl:system/etc/terminfo/t/tek4106brl \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4025ex:system/etc/terminfo/t/tek4025ex \
    vendor/cm/prebuilt/common/etc/terminfo/t/ts100-ctxt:system/etc/terminfo/t/ts100-ctxt \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4113:system/etc/terminfo/t/tek4113 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi925:system/etc/terminfo/t/tvi925 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi950-2p:system/etc/terminfo/t/tvi950-2p \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi92D:system/etc/terminfo/t/tvi92D \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi950-rv-4p:system/etc/terminfo/t/tvi950-rv-4p \
    vendor/cm/prebuilt/common/etc/terminfo/t/t10:system/etc/terminfo/t/t10 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4205:system/etc/terminfo/t/tek4205 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi970-2p:system/etc/terminfo/t/tvi970-2p \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4107:system/etc/terminfo/t/tek4107 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi910+:system/etc/terminfo/t/tvi910+ \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi912-2p:system/etc/terminfo/t/tvi912-2p \
    vendor/cm/prebuilt/common/etc/terminfo/t/tty43:system/etc/terminfo/t/tty43 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4024:system/etc/terminfo/t/tek4024 \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti924w:system/etc/terminfo/t/ti924w \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4105:system/etc/terminfo/t/tek4105 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tws2103:system/etc/terminfo/t/tws2103 \
    vendor/cm/prebuilt/common/etc/terminfo/t/teletec:system/etc/terminfo/t/teletec \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi955:system/etc/terminfo/t/tvi955 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4112:system/etc/terminfo/t/tek4112 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi925-hi:system/etc/terminfo/t/tvi925-hi \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti_ansi:system/etc/terminfo/t/ti_ansi \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti928:system/etc/terminfo/t/ti928 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4025-17-ws:system/etc/terminfo/t/tek4025-17-ws \
    vendor/cm/prebuilt/common/etc/terminfo/t/t3700:system/etc/terminfo/t/t3700 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tt505-22:system/etc/terminfo/t/tt505-22 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi912:system/etc/terminfo/t/tvi912 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4013:system/etc/terminfo/t/tek4013 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi910:system/etc/terminfo/t/tvi910 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi803:system/etc/terminfo/t/tvi803 \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti916-8-132:system/etc/terminfo/t/ti916-8-132 \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti931:system/etc/terminfo/t/ti931 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tab132-w-rv:system/etc/terminfo/t/tab132-w-rv \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti916-132:system/etc/terminfo/t/ti916-132 \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti916:system/etc/terminfo/t/ti916 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tty37:system/etc/terminfo/t/tty37 \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti928-8:system/etc/terminfo/t/ti928-8 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4025-ex:system/etc/terminfo/t/tek4025-ex \
    vendor/cm/prebuilt/common/etc/terminfo/t/tandem6510:system/etc/terminfo/t/tandem6510 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi92B:system/etc/terminfo/t/tvi92B \
    vendor/cm/prebuilt/common/etc/terminfo/t/terminet1200:system/etc/terminfo/t/terminet1200 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4207:system/etc/terminfo/t/tek4207 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tandem653:system/etc/terminfo/t/tandem653 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek:system/etc/terminfo/t/tek \
    vendor/cm/prebuilt/common/etc/terminfo/t/teraterm:system/etc/terminfo/t/teraterm \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti924-8w:system/etc/terminfo/t/ti924-8w \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4125:system/etc/terminfo/t/tek4125 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4025-cr:system/etc/terminfo/t/tek4025-cr \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi912cc:system/etc/terminfo/t/tvi912cc \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvipt:system/etc/terminfo/t/tvipt \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi950-4p:system/etc/terminfo/t/tvi950-4p \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi950:system/etc/terminfo/t/tvi950 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi924:system/etc/terminfo/t/tvi924 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tvi970-vb:system/etc/terminfo/t/tvi970-vb \
    vendor/cm/prebuilt/common/etc/terminfo/t/tek4113-34:system/etc/terminfo/t/tek4113-34 \
    vendor/cm/prebuilt/common/etc/terminfo/t/t1061f:system/etc/terminfo/t/t1061f \
    vendor/cm/prebuilt/common/etc/terminfo/t/ts100:system/etc/terminfo/t/ts100 \
    vendor/cm/prebuilt/common/etc/terminfo/t/tws2102-sna:system/etc/terminfo/t/tws2102-sna \
    vendor/cm/prebuilt/common/etc/terminfo/t/ti926-8:system/etc/terminfo/t/ti926-8 \
    vendor/cm/prebuilt/common/etc/terminfo/j/jaixterm-m:system/etc/terminfo/j/jaixterm-m \
    vendor/cm/prebuilt/common/etc/terminfo/j/jaixterm:system/etc/terminfo/j/jaixterm \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-sr-ccc:system/etc/terminfo/d/d430c-unix-sr-ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgmode+color8:system/etc/terminfo/d/dgmode+color8 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dw3:system/etc/terminfo/d/dw3 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg460-ansi:system/etc/terminfo/d/dg460-ansi \
    vendor/cm/prebuilt/common/etc/terminfo/d/dp8242:system/etc/terminfo/d/dp8242 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgunix+ccc:system/etc/terminfo/d/dgunix+ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/d410:system/etc/terminfo/d/d410 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d470c:system/etc/terminfo/d/d470c \
    vendor/cm/prebuilt/common/etc/terminfo/d/dmterm:system/etc/terminfo/d/dmterm \
    vendor/cm/prebuilt/common/etc/terminfo/d/dw4:system/etc/terminfo/d/dw4 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dku7102-old:system/etc/terminfo/d/dku7102-old \
    vendor/cm/prebuilt/common/etc/terminfo/d/dm3045:system/etc/terminfo/d/dm3045 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dmchat:system/etc/terminfo/d/dmchat \
    vendor/cm/prebuilt/common/etc/terminfo/d/d220-7b:system/etc/terminfo/d/d220-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/dm1520:system/etc/terminfo/d/dm1520 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d220-dg:system/etc/terminfo/d/d220-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg-generic:system/etc/terminfo/d/dg-generic \
    vendor/cm/prebuilt/common/etc/terminfo/d/d412-dg:system/etc/terminfo/d/d412-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d211:system/etc/terminfo/d/d211 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d414-unix-25:system/etc/terminfo/d/d414-unix-25 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d230c:system/etc/terminfo/d/d230c \
    vendor/cm/prebuilt/common/etc/terminfo/d/d413-unix-25:system/etc/terminfo/d/d413-unix-25 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-w:system/etc/terminfo/d/d430c-unix-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d216-dg:system/etc/terminfo/d/d216-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d132:system/etc/terminfo/d/d132 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgmode+color:system/etc/terminfo/d/dgmode+color \
    vendor/cm/prebuilt/common/etc/terminfo/d/dm3025:system/etc/terminfo/d/dm3025 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d555-w:system/etc/terminfo/d/d555-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d410-7b-w:system/etc/terminfo/d/d410-7b-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d414-unix:system/etc/terminfo/d/d414-unix \
    vendor/cm/prebuilt/common/etc/terminfo/d/d577-w:system/etc/terminfo/d/d577-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/dt110:system/etc/terminfo/d/dt110 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d577:system/etc/terminfo/d/d577 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-25-ccc:system/etc/terminfo/d/d430c-unix-25-ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/dt80-sas:system/etc/terminfo/d/dt80-sas \
    vendor/cm/prebuilt/common/etc/terminfo/d/d210:system/etc/terminfo/d/d210 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-s:system/etc/terminfo/d/d430c-unix-s \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg200:system/etc/terminfo/d/dg200 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d410-7b:system/etc/terminfo/d/d410-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg+color8:system/etc/terminfo/d/dg+color8 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d578:system/etc/terminfo/d/d578 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d412-unix:system/etc/terminfo/d/d412-unix \
    vendor/cm/prebuilt/common/etc/terminfo/d/dw2:system/etc/terminfo/d/dw2 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dku7003-dumb:system/etc/terminfo/d/dku7003-dumb \
    vendor/cm/prebuilt/common/etc/terminfo/d/dm2500:system/etc/terminfo/d/dm2500 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d211-dg:system/etc/terminfo/d/d211-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d217-unix-25:system/etc/terminfo/d/d217-unix-25 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d800:system/etc/terminfo/d/d800 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d555-dg:system/etc/terminfo/d/d555-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg+ccc:system/etc/terminfo/d/dg+ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-25:system/etc/terminfo/d/d430c-unix-25 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgunix+fixed:system/etc/terminfo/d/dgunix+fixed \
    vendor/cm/prebuilt/common/etc/terminfo/d/d400:system/etc/terminfo/d/d400 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dwk:system/etc/terminfo/d/dwk \
    vendor/cm/prebuilt/common/etc/terminfo/d/d414-unix-sr:system/etc/terminfo/d/d414-unix-sr \
    vendor/cm/prebuilt/common/etc/terminfo/d/dp3360:system/etc/terminfo/d/dp3360 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dku7202:system/etc/terminfo/d/dku7202 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dt100w:system/etc/terminfo/d/dt100w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d470c-7b:system/etc/terminfo/d/d470c-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg6053:system/etc/terminfo/d/dg6053 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d210-dg:system/etc/terminfo/d/d210-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d414-unix-s:system/etc/terminfo/d/d414-unix-s \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg210:system/etc/terminfo/d/dg210 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgkeys+7b:system/etc/terminfo/d/dgkeys+7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/d555:system/etc/terminfo/d/d555 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dec-vt220:system/etc/terminfo/d/dec-vt220 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dm80:system/etc/terminfo/d/dm80 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dec-vt100:system/etc/terminfo/d/dec-vt100 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d216-unix:system/etc/terminfo/d/d216-unix \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-dg-ccc:system/etc/terminfo/d/d430c-dg-ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/dt100:system/etc/terminfo/d/dt100 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgkeys+11:system/etc/terminfo/d/dgkeys+11 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d412-unix-25:system/etc/terminfo/d/d412-unix-25 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d413-unix-s:system/etc/terminfo/d/d413-unix-s \
    vendor/cm/prebuilt/common/etc/terminfo/d/dm80w:system/etc/terminfo/d/dm80w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d412-unix-s:system/etc/terminfo/d/d412-unix-s \
    vendor/cm/prebuilt/common/etc/terminfo/d/d413-unix-sr:system/etc/terminfo/d/d413-unix-sr \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-s-ccc:system/etc/terminfo/d/d430c-unix-s-ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/d412-unix-w:system/etc/terminfo/d/d412-unix-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d413-unix-w:system/etc/terminfo/d/d413-unix-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d555-7b-w:system/etc/terminfo/d/d555-7b-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgkeys+8b:system/etc/terminfo/d/dgkeys+8b \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-sr:system/etc/terminfo/d/d430c-unix-sr \
    vendor/cm/prebuilt/common/etc/terminfo/d/d410-dg:system/etc/terminfo/d/d410-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d555-7b:system/etc/terminfo/d/d555-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/d578-7b:system/etc/terminfo/d/d578-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg+color:system/etc/terminfo/d/dg+color \
    vendor/cm/prebuilt/common/etc/terminfo/d/dgkeys+15:system/etc/terminfo/d/dgkeys+15 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-ccc:system/etc/terminfo/d/d430c-unix-ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg+fixed:system/etc/terminfo/d/dg+fixed \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg450:system/etc/terminfo/d/dg450 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d217-unix:system/etc/terminfo/d/d217-unix \
    vendor/cm/prebuilt/common/etc/terminfo/d/d577-7b:system/etc/terminfo/d/d577-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/delta:system/etc/terminfo/d/delta \
    vendor/cm/prebuilt/common/etc/terminfo/d/d216-unix-25:system/etc/terminfo/d/d216-unix-25 \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg6053-old:system/etc/terminfo/d/dg6053-old \
    vendor/cm/prebuilt/common/etc/terminfo/d/d413-unix:system/etc/terminfo/d/d413-unix \
    vendor/cm/prebuilt/common/etc/terminfo/d/dw1:system/etc/terminfo/d/dw1 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d230c-dg:system/etc/terminfo/d/d230c-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-dg:system/etc/terminfo/d/d430c-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/dg211:system/etc/terminfo/d/dg211 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d577-dg:system/etc/terminfo/d/d577-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d200:system/etc/terminfo/d/d200 \
    vendor/cm/prebuilt/common/etc/terminfo/d/ddr:system/etc/terminfo/d/ddr \
    vendor/cm/prebuilt/common/etc/terminfo/d/d412-unix-sr:system/etc/terminfo/d/d412-unix-sr \
    vendor/cm/prebuilt/common/etc/terminfo/d/d470c-dg:system/etc/terminfo/d/d470c-dg \
    vendor/cm/prebuilt/common/etc/terminfo/d/d220:system/etc/terminfo/d/d220 \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix-w-ccc:system/etc/terminfo/d/d430c-unix-w-ccc \
    vendor/cm/prebuilt/common/etc/terminfo/d/d577-7b-w:system/etc/terminfo/d/d577-7b-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/d430c-unix:system/etc/terminfo/d/d430c-unix \
    vendor/cm/prebuilt/common/etc/terminfo/d/d211-7b:system/etc/terminfo/d/d211-7b \
    vendor/cm/prebuilt/common/etc/terminfo/d/d410-w:system/etc/terminfo/d/d410-w \
    vendor/cm/prebuilt/common/etc/terminfo/d/dtterm:system/etc/terminfo/d/dtterm \
    vendor/cm/prebuilt/common/etc/terminfo/d/dku7003:system/etc/terminfo/d/dku7003 \
    vendor/cm/prebuilt/common/etc/terminfo/d/digilog:system/etc/terminfo/d/digilog \
    vendor/cm/prebuilt/common/etc/terminfo/d/dumb:system/etc/terminfo/d/dumb \
    vendor/cm/prebuilt/common/etc/terminfo/d/d414-unix-w:system/etc/terminfo/d/d414-unix-w \
    vendor/cm/prebuilt/common/etc/terminfo/c/coco3:system/etc/terminfo/c/coco3 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons50:system/etc/terminfo/c/cons50 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cyb83:system/etc/terminfo/c/cyb83 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit101:system/etc/terminfo/c/cit101 \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh-comp:system/etc/terminfo/c/citoh-comp \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh-8lpi:system/etc/terminfo/c/citoh-8lpi \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25r:system/etc/terminfo/c/cons25r \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh-pica:system/etc/terminfo/c/citoh-pica \
    vendor/cm/prebuilt/common/etc/terminfo/c/cdc721-esc:system/etc/terminfo/c/cdc721-esc \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons30-m:system/etc/terminfo/c/cons30-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/crt:system/etc/terminfo/c/crt \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh:system/etc/terminfo/c/citoh \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh-elite:system/etc/terminfo/c/citoh-elite \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons60l1-m:system/etc/terminfo/c/cons60l1-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit500:system/etc/terminfo/c/cit500 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cg7900:system/etc/terminfo/c/cg7900 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons50-m:system/etc/terminfo/c/cons50-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cdc721:system/etc/terminfo/c/cdc721 \
    vendor/cm/prebuilt/common/etc/terminfo/c/commodore:system/etc/terminfo/c/commodore \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons60r:system/etc/terminfo/c/cons60r \
    vendor/cm/prebuilt/common/etc/terminfo/c/ca22851:system/etc/terminfo/c/ca22851 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25r-m:system/etc/terminfo/c/cons25r-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/c108-4p:system/etc/terminfo/c/c108-4p \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit101e-rv:system/etc/terminfo/c/cit101e-rv \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25w:system/etc/terminfo/c/cons25w \
    vendor/cm/prebuilt/common/etc/terminfo/c/c100-rv:system/etc/terminfo/c/c100-rv \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh-prop:system/etc/terminfo/c/citoh-prop \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit101e-132:system/etc/terminfo/c/cit101e-132 \
    vendor/cm/prebuilt/common/etc/terminfo/c/color_xterm:system/etc/terminfo/c/color_xterm \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25l1-m:system/etc/terminfo/c/cons25l1-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/c108-rv-4p:system/etc/terminfo/c/c108-rv-4p \
    vendor/cm/prebuilt/common/etc/terminfo/c/c108:system/etc/terminfo/c/c108 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons30:system/etc/terminfo/c/cons30 \
    vendor/cm/prebuilt/common/etc/terminfo/c/c108-w:system/etc/terminfo/c/c108-w \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons43-m:system/etc/terminfo/c/cons43-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons43:system/etc/terminfo/c/cons43 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cci:system/etc/terminfo/c/cci \
    vendor/cm/prebuilt/common/etc/terminfo/c/cad68-3:system/etc/terminfo/c/cad68-3 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons50r-m:system/etc/terminfo/c/cons50r-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cs10-w:system/etc/terminfo/c/cs10-w \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons50l1:system/etc/terminfo/c/cons50l1 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cbblit:system/etc/terminfo/c/cbblit \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit101e-n:system/etc/terminfo/c/cit101e-n \
    vendor/cm/prebuilt/common/etc/terminfo/c/cdc456:system/etc/terminfo/c/cdc456 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons60r-m:system/etc/terminfo/c/cons60r-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cyb110:system/etc/terminfo/c/cyb110 \
    vendor/cm/prebuilt/common/etc/terminfo/c/c108-rv:system/etc/terminfo/c/c108-rv \
    vendor/cm/prebuilt/common/etc/terminfo/c/cdc752:system/etc/terminfo/c/cdc752 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cygwin:system/etc/terminfo/c/cygwin \
    vendor/cm/prebuilt/common/etc/terminfo/c/c100:system/etc/terminfo/c/c100 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cdc721ll:system/etc/terminfo/c/cdc721ll \
    vendor/cm/prebuilt/common/etc/terminfo/c/cops10:system/etc/terminfo/c/cops10 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons60-m:system/etc/terminfo/c/cons60-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons50r:system/etc/terminfo/c/cons50r \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit80:system/etc/terminfo/c/cit80 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cad68-2:system/etc/terminfo/c/cad68-2 \
    vendor/cm/prebuilt/common/etc/terminfo/c/contel301:system/etc/terminfo/c/contel301 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit101e-n132:system/etc/terminfo/c/cit101e-n132 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25-m:system/etc/terminfo/c/cons25-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cbunix:system/etc/terminfo/c/cbunix \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25:system/etc/terminfo/c/cons25 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons60l1:system/etc/terminfo/c/cons60l1 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cs10:system/etc/terminfo/c/cs10 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons50l1-m:system/etc/terminfo/c/cons50l1-m \
    vendor/cm/prebuilt/common/etc/terminfo/c/cdc756:system/etc/terminfo/c/cdc756 \
    vendor/cm/prebuilt/common/etc/terminfo/c/ctrm:system/etc/terminfo/c/ctrm \
    vendor/cm/prebuilt/common/etc/terminfo/c/citoh-6lpi:system/etc/terminfo/c/citoh-6lpi \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons60:system/etc/terminfo/c/cons60 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cons25l1:system/etc/terminfo/c/cons25l1 \
    vendor/cm/prebuilt/common/etc/terminfo/c/cit101e:system/etc/terminfo/c/cit101e \
    vendor/cm/prebuilt/common/etc/terminfo/c/contel300:system/etc/terminfo/c/contel300 \
    vendor/cm/prebuilt/common/etc/terminfo/c/ct8500:system/etc/terminfo/c/ct8500 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism14-w:system/etc/terminfo/p/prism14-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/psterm-96x48:system/etc/terminfo/p/psterm-96x48 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt28:system/etc/terminfo/p/pcvt28 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt40:system/etc/terminfo/p/pcvt40 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-m:system/etc/terminfo/p/pcansi-m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pilot:system/etc/terminfo/p/pilot \
    vendor/cm/prebuilt/common/etc/terminfo/p/ps300:system/etc/terminfo/p/ps300 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pe1251:system/etc/terminfo/p/pe1251 \
    vendor/cm/prebuilt/common/etc/terminfo/p/psterm-fast:system/etc/terminfo/p/psterm-fast \
    vendor/cm/prebuilt/common/etc/terminfo/p/pckermit120:system/etc/terminfo/p/pckermit120 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt25w:system/etc/terminfo/p/pcvt25w \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism4:system/etc/terminfo/p/prism4 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pe7000m:system/etc/terminfo/p/pe7000m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvtXX:system/etc/terminfo/p/pcvtXX \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt40w:system/etc/terminfo/p/pcvt40w \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism9:system/etc/terminfo/p/prism9 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pe7000c:system/etc/terminfo/p/pe7000c \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi:system/etc/terminfo/p/pcansi \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism9-8:system/etc/terminfo/p/prism9-8 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-25:system/etc/terminfo/p/pcansi-25 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism8-w:system/etc/terminfo/p/prism8-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pccons:system/etc/terminfo/p/pccons \
    vendor/cm/prebuilt/common/etc/terminfo/p/pc3:system/etc/terminfo/p/pc3 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism7:system/etc/terminfo/p/prism7 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism2:system/etc/terminfo/p/prism2 \
    vendor/cm/prebuilt/common/etc/terminfo/p/p19:system/etc/terminfo/p/p19 \
    vendor/cm/prebuilt/common/etc/terminfo/p/psterm:system/etc/terminfo/p/psterm \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism14:system/etc/terminfo/p/prism14 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism14-m:system/etc/terminfo/p/prism14-m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcplot:system/etc/terminfo/p/pcplot \
    vendor/cm/prebuilt/common/etc/terminfo/p/p8gl:system/etc/terminfo/p/p8gl \
    vendor/cm/prebuilt/common/etc/terminfo/p/pc6300plus:system/etc/terminfo/p/pc6300plus \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism12-w:system/etc/terminfo/p/prism12-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/psterm-90x28:system/etc/terminfo/p/psterm-90x28 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism9-8-w:system/etc/terminfo/p/prism9-8-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pckermit:system/etc/terminfo/p/pckermit \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-33-m:system/etc/terminfo/p/pcansi-33-m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-33:system/etc/terminfo/p/pcansi-33 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcmw:system/etc/terminfo/p/pcmw \
    vendor/cm/prebuilt/common/etc/terminfo/p/pc-minix:system/etc/terminfo/p/pc-minix \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt35:system/etc/terminfo/p/pcvt35 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt43:system/etc/terminfo/p/pcvt43 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt43w:system/etc/terminfo/p/pcvt43w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt35w:system/etc/terminfo/p/pcvt35w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt28w:system/etc/terminfo/p/pcvt28w \
    vendor/cm/prebuilt/common/etc/terminfo/p/psterm-80x24:system/etc/terminfo/p/psterm-80x24 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pro350:system/etc/terminfo/p/pro350 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-25-m:system/etc/terminfo/p/pcansi-25-m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt50w:system/etc/terminfo/p/pcvt50w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pmcons:system/etc/terminfo/p/pmcons \
    vendor/cm/prebuilt/common/etc/terminfo/p/pty:system/etc/terminfo/p/pty \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt50:system/etc/terminfo/p/pcvt50 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pc-coherent:system/etc/terminfo/p/pc-coherent \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcix:system/etc/terminfo/p/pcix \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism12:system/etc/terminfo/p/prism12 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pt250:system/etc/terminfo/p/pt250 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pc-venix:system/etc/terminfo/p/pc-venix \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism9-w:system/etc/terminfo/p/prism9-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-43-m:system/etc/terminfo/p/pcansi-43-m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pt100:system/etc/terminfo/p/pt100 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism8:system/etc/terminfo/p/prism8 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcansi-43:system/etc/terminfo/p/pcansi-43 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pcvt25:system/etc/terminfo/p/pcvt25 \
    vendor/cm/prebuilt/common/etc/terminfo/p/pt210:system/etc/terminfo/p/pt210 \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism14-m-w:system/etc/terminfo/p/prism14-m-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism12-m:system/etc/terminfo/p/prism12-m \
    vendor/cm/prebuilt/common/etc/terminfo/p/pt250w:system/etc/terminfo/p/pt250w \
    vendor/cm/prebuilt/common/etc/terminfo/p/pt100w:system/etc/terminfo/p/pt100w \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism12-m-w:system/etc/terminfo/p/prism12-m-w \
    vendor/cm/prebuilt/common/etc/terminfo/p/prism5:system/etc/terminfo/p/prism5 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-8bit:system/etc/terminfo/x/xterm-8bit \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-xi:system/etc/terminfo/x/xterm-xi \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm:system/etc/terminfo/x/xterm \
    vendor/cm/prebuilt/common/etc/terminfo/x/xtermc:system/etc/terminfo/x/xtermc \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-r6:system/etc/terminfo/x/xterm-r6 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-24:system/etc/terminfo/x/xterm-24 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xtalk:system/etc/terminfo/x/xtalk \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-pcolor:system/etc/terminfo/x/xterm-pcolor \
    vendor/cm/prebuilt/common/etc/terminfo/x/xtermm:system/etc/terminfo/x/xtermm \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-bold:system/etc/terminfo/x/xterm-bold \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm+sl:system/etc/terminfo/x/xterm+sl \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-xf86-v40:system/etc/terminfo/x/xterm-xf86-v40 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-xf86-v33:system/etc/terminfo/x/xterm-xf86-v33 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xerox820:system/etc/terminfo/x/xerox820 \
    vendor/cm/prebuilt/common/etc/terminfo/x/x68k:system/etc/terminfo/x/x68k \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-sun:system/etc/terminfo/x/xterm-sun \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm+sl-twm:system/etc/terminfo/x/xterm+sl-twm \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterms-sun:system/etc/terminfo/x/xterms-sun \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm1:system/etc/terminfo/x/xterm1 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-nic:system/etc/terminfo/x/xterm-nic \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-xf86-v32:system/etc/terminfo/x/xterm-xf86-v32 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-xfree86:system/etc/terminfo/x/xterm-xfree86 \
    vendor/cm/prebuilt/common/etc/terminfo/x/x10term:system/etc/terminfo/x/x10term \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-16color:system/etc/terminfo/x/xterm-16color \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-r5:system/etc/terminfo/x/xterm-r5 \
    vendor/cm/prebuilt/common/etc/terminfo/x/xterm-xf86-v333:system/etc/terminfo/x/xterm-xf86-v333 \
    vendor/cm/prebuilt/common/etc/terminfo/f/fos:system/etc/terminfo/f/fos \
    vendor/cm/prebuilt/common/etc/terminfo/f/f110-w:system/etc/terminfo/f/f110-w \
    vendor/cm/prebuilt/common/etc/terminfo/f/f110-14w:system/etc/terminfo/f/f110-14w \
    vendor/cm/prebuilt/common/etc/terminfo/f/falco-p:system/etc/terminfo/f/falco-p \
    vendor/cm/prebuilt/common/etc/terminfo/f/falco:system/etc/terminfo/f/falco \
    vendor/cm/prebuilt/common/etc/terminfo/f/f200vi:system/etc/terminfo/f/f200vi \
    vendor/cm/prebuilt/common/etc/terminfo/f/f1720:system/etc/terminfo/f/f1720 \
    vendor/cm/prebuilt/common/etc/terminfo/f/f110:system/etc/terminfo/f/f110 \
    vendor/cm/prebuilt/common/etc/terminfo/f/f100:system/etc/terminfo/f/f100 \
    vendor/cm/prebuilt/common/etc/terminfo/f/f200-w:system/etc/terminfo/f/f200-w \
    vendor/cm/prebuilt/common/etc/terminfo/f/fox:system/etc/terminfo/f/fox \
    vendor/cm/prebuilt/common/etc/terminfo/f/f100-rv:system/etc/terminfo/f/f100-rv \
    vendor/cm/prebuilt/common/etc/terminfo/f/f110-14:system/etc/terminfo/f/f110-14 \
    vendor/cm/prebuilt/common/etc/terminfo/f/f200vi-w:system/etc/terminfo/f/f200vi-w \
    vendor/cm/prebuilt/common/etc/terminfo/f/f200:system/etc/terminfo/f/f200 \
    vendor/cm/prebuilt/common/etc/terminfo/u/uniterm:system/etc/terminfo/u/uniterm \
    vendor/cm/prebuilt/common/etc/terminfo/u/uts30:system/etc/terminfo/u/uts30 \
    vendor/cm/prebuilt/common/etc/terminfo/u/unknown:system/etc/terminfo/u/unknown \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-24:system/etc/terminfo/a/aaa-24 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-mini:system/etc/terminfo/a/ansi-mini \
    vendor/cm/prebuilt/common/etc/terminfo/a/att630:system/etc/terminfo/a/att630 \
    vendor/cm/prebuilt/common/etc/terminfo/a/avatar:system/etc/terminfo/a/avatar \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415:system/etc/terminfo/a/att4415 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att730r-41:system/etc/terminfo/a/att730r-41 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-22:system/etc/terminfo/a/aaa-22 \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-rv-ns:system/etc/terminfo/a/avt-rv-ns \
    vendor/cm/prebuilt/common/etc/terminfo/a/adds980:system/etc/terminfo/a/adds980 \
    vendor/cm/prebuilt/common/etc/terminfo/a/appleIIgs:system/etc/terminfo/a/appleIIgs \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-w:system/etc/terminfo/a/avt-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4410v1-w:system/etc/terminfo/a/att4410v1-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/att510d:system/etc/terminfo/a/att510d \
    vendor/cm/prebuilt/common/etc/terminfo/a/abm85:system/etc/terminfo/a/abm85 \
    vendor/cm/prebuilt/common/etc/terminfo/a/addrinfo:system/etc/terminfo/a/addrinfo \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-30-s-rv:system/etc/terminfo/a/aaa-30-s-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5425-nl:system/etc/terminfo/a/att5425-nl \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5410-w:system/etc/terminfo/a/att5410-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-28:system/etc/terminfo/a/aaa-28 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+pp:system/etc/terminfo/a/ansi+pp \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-s-ctxt:system/etc/terminfo/a/aaa-s-ctxt \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-36-rv:system/etc/terminfo/a/aaa-36-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4418-w:system/etc/terminfo/a/att4418-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/aepro:system/etc/terminfo/a/aepro \
    vendor/cm/prebuilt/common/etc/terminfo/a/annarbor4080:system/etc/terminfo/a/annarbor4080 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm11:system/etc/terminfo/a/adm11 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4424:system/etc/terminfo/a/att4424 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm42:system/etc/terminfo/a/adm42 \
    vendor/cm/prebuilt/common/etc/terminfo/a/arm100-w:system/etc/terminfo/a/arm100-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5620-1:system/etc/terminfo/a/att5620-1 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-m:system/etc/terminfo/a/ansi-m \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm5:system/etc/terminfo/a/adm5 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aas1901:system/etc/terminfo/a/aas1901 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att500:system/etc/terminfo/a/att500 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm3:system/etc/terminfo/a/adm3 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex175:system/etc/terminfo/a/ampex175 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm31-old:system/etc/terminfo/a/adm31-old \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-nt:system/etc/terminfo/a/ansi-nt \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi.sysk:system/etc/terminfo/a/ansi.sysk \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple2e-p:system/etc/terminfo/a/apple2e-p \
    vendor/cm/prebuilt/common/etc/terminfo/a/aixterm:system/etc/terminfo/a/aixterm \
    vendor/cm/prebuilt/common/etc/terminfo/a/amiga-h:system/etc/terminfo/a/amiga-h \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-s-rv-ctxt:system/etc/terminfo/a/aaa-s-rv-ctxt \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-generic:system/etc/terminfo/a/ansi-generic \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5620-34:system/etc/terminfo/a/att5620-34 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-20:system/etc/terminfo/a/aaa-20 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+tabs:system/etc/terminfo/a/ansi+tabs \
    vendor/cm/prebuilt/common/etc/terminfo/a/aixterm-m-old:system/etc/terminfo/a/aixterm-m-old \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa+unk:system/etc/terminfo/a/aaa+unk \
    vendor/cm/prebuilt/common/etc/terminfo/a/att605:system/etc/terminfo/a/att605 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-mtabs:system/etc/terminfo/a/ansi-mtabs \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex175-b:system/etc/terminfo/a/ampex175-b \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex232w:system/etc/terminfo/a/ampex232w \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-w-rv:system/etc/terminfo/a/avt-w-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att615:system/etc/terminfo/a/att615 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-mr:system/etc/terminfo/a/ansi-mr \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-30-s:system/etc/terminfo/a/aaa-30-s \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm42-ns:system/etc/terminfo/a/adm42-ns \
    vendor/cm/prebuilt/common/etc/terminfo/a/apollo:system/etc/terminfo/a/apollo \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-ae:system/etc/terminfo/a/apple-ae \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4420:system/etc/terminfo/a/att4420 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att610:system/etc/terminfo/a/att610 \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-80:system/etc/terminfo/a/apple-80 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-rv-nl:system/etc/terminfo/a/att4415-rv-nl \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5425:system/etc/terminfo/a/att5425 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aixterm-m:system/etc/terminfo/a/aixterm-m \
    vendor/cm/prebuilt/common/etc/terminfo/a/att605-pc:system/etc/terminfo/a/att605-pc \
    vendor/cm/prebuilt/common/etc/terminfo/a/att730-24:system/etc/terminfo/a/att730-24 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm3a:system/etc/terminfo/a/adm3a \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+erase:system/etc/terminfo/a/ansi+erase \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+csr:system/etc/terminfo/a/ansi+csr \
    vendor/cm/prebuilt/common/etc/terminfo/a/att620-w:system/etc/terminfo/a/att620-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex80:system/etc/terminfo/a/ampex80 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att615-103k-w:system/etc/terminfo/a/att615-103k-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple80p:system/etc/terminfo/a/apple80p \
    vendor/cm/prebuilt/common/etc/terminfo/a/abm85h:system/etc/terminfo/a/abm85h \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+inittabs:system/etc/terminfo/a/ansi+inittabs \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt:system/etc/terminfo/a/avt \
    vendor/cm/prebuilt/common/etc/terminfo/a/att2300:system/etc/terminfo/a/att2300 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-w:system/etc/terminfo/a/att4415-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa+dec:system/etc/terminfo/a/aaa+dec \
    vendor/cm/prebuilt/common/etc/terminfo/a/altos2:system/etc/terminfo/a/altos2 \
    vendor/cm/prebuilt/common/etc/terminfo/a/act5:system/etc/terminfo/a/act5 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm+sgr:system/etc/terminfo/a/adm+sgr \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-uterm:system/etc/terminfo/a/apple-uterm \
    vendor/cm/prebuilt/common/etc/terminfo/a/att700:system/etc/terminfo/a/att700 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-30-rv:system/etc/terminfo/a/aaa-30-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/apollo_15P:system/etc/terminfo/a/apollo_15P \
    vendor/cm/prebuilt/common/etc/terminfo/a/altos3:system/etc/terminfo/a/altos3 \
    vendor/cm/prebuilt/common/etc/terminfo/a/abm80:system/etc/terminfo/a/abm80 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+idl1:system/etc/terminfo/a/ansi+idl1 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5410v1:system/etc/terminfo/a/att5410v1 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex219:system/etc/terminfo/a/ampex219 \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-soroc:system/etc/terminfo/a/apple-soroc \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+sgrdim:system/etc/terminfo/a/ansi+sgrdim \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-24-rv:system/etc/terminfo/a/aaa-24-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-w-rv-ns:system/etc/terminfo/a/avt-w-rv-ns \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple2e:system/etc/terminfo/a/apple2e \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-18:system/etc/terminfo/a/aaa-18 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att615-103k:system/etc/terminfo/a/att615-103k \
    vendor/cm/prebuilt/common/etc/terminfo/a/alto-h19:system/etc/terminfo/a/alto-h19 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att620-103k-w:system/etc/terminfo/a/att620-103k-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm12:system/etc/terminfo/a/adm12 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi:system/etc/terminfo/a/ansi \
    vendor/cm/prebuilt/common/etc/terminfo/a/abm85e:system/etc/terminfo/a/abm85e \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt+s:system/etc/terminfo/a/avt+s \
    vendor/cm/prebuilt/common/etc/terminfo/a/awsc:system/etc/terminfo/a/awsc \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-w-rv-n:system/etc/terminfo/a/att4415-w-rv-n \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-30-ctxt:system/etc/terminfo/a/aaa-30-ctxt \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-60-dec-rv:system/etc/terminfo/a/aaa-60-dec-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi.sys-old:system/etc/terminfo/a/ansi.sys-old \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-ns:system/etc/terminfo/a/avt-ns \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-40-rv:system/etc/terminfo/a/aaa-40-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-nl:system/etc/terminfo/a/att4415-nl \
    vendor/cm/prebuilt/common/etc/terminfo/a/act4:system/etc/terminfo/a/act4 \
    vendor/cm/prebuilt/common/etc/terminfo/a/altos7pc:system/etc/terminfo/a/altos7pc \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5310:system/etc/terminfo/a/att5310 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att620:system/etc/terminfo/a/att620 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-18-rv:system/etc/terminfo/a/aaa-18-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/arm100:system/etc/terminfo/a/arm100 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-60:system/etc/terminfo/a/aaa-60 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm1a:system/etc/terminfo/a/adm1a \
    vendor/cm/prebuilt/common/etc/terminfo/a/appleII:system/etc/terminfo/a/appleII \
    vendor/cm/prebuilt/common/etc/terminfo/a/apollo_19L:system/etc/terminfo/a/apollo_19L \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-uterm-vb:system/etc/terminfo/a/apple-uterm-vb \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+cup:system/etc/terminfo/a/ansi+cup \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4426:system/etc/terminfo/a/att4426 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5420_2:system/etc/terminfo/a/att5420_2 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att6386:system/etc/terminfo/a/att6386 \
    vendor/cm/prebuilt/common/etc/terminfo/a/avatar0+:system/etc/terminfo/a/avatar0+ \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex232:system/etc/terminfo/a/ampex232 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att7300:system/etc/terminfo/a/att7300 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi.sys:system/etc/terminfo/a/ansi.sys \
    vendor/cm/prebuilt/common/etc/terminfo/a/atari:system/etc/terminfo/a/atari \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5425-w:system/etc/terminfo/a/att5425-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+sgrso:system/etc/terminfo/a/ansi+sgrso \
    vendor/cm/prebuilt/common/etc/terminfo/a/att615-w:system/etc/terminfo/a/att615-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/att610-103k-w:system/etc/terminfo/a/att610-103k-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm3a+:system/etc/terminfo/a/adm3a+ \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-60-s:system/etc/terminfo/a/aaa-60-s \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+rca:system/etc/terminfo/a/ansi+rca \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+rep:system/etc/terminfo/a/ansi+rep \
    vendor/cm/prebuilt/common/etc/terminfo/a/att730-41:system/etc/terminfo/a/att730-41 \
    vendor/cm/prebuilt/common/etc/terminfo/a/amiga-8bit:system/etc/terminfo/a/amiga-8bit \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-30-rv-ctxt:system/etc/terminfo/a/aaa-30-rv-ctxt \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+arrows:system/etc/terminfo/a/ansi+arrows \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi77:system/etc/terminfo/a/ansi77 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm36:system/etc/terminfo/a/adm36 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5620-s:system/etc/terminfo/a/att5620-s \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-color-2-emx:system/etc/terminfo/a/ansi-color-2-emx \
    vendor/cm/prebuilt/common/etc/terminfo/a/att620-103k:system/etc/terminfo/a/att620-103k \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm21:system/etc/terminfo/a/adm21 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm22:system/etc/terminfo/a/adm22 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-40:system/etc/terminfo/a/aaa-40 \
    vendor/cm/prebuilt/common/etc/terminfo/a/altos7:system/etc/terminfo/a/altos7 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa+rv:system/etc/terminfo/a/aaa+rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5620:system/etc/terminfo/a/att5620 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-color-3-emx:system/etc/terminfo/a/ansi-color-3-emx \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+idl:system/etc/terminfo/a/ansi+idl \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi-emx:system/etc/terminfo/a/ansi-emx \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-60-s-rv:system/etc/terminfo/a/aaa-60-s-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att2350:system/etc/terminfo/a/att2350 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-w-rv:system/etc/terminfo/a/att4415-w-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att730:system/etc/terminfo/a/att730 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm1178:system/etc/terminfo/a/adm1178 \
    vendor/cm/prebuilt/common/etc/terminfo/a/altos4:system/etc/terminfo/a/altos4 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex219w:system/etc/terminfo/a/ampex219w \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-48:system/etc/terminfo/a/aaa-48 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+idc:system/etc/terminfo/a/ansi+idc \
    vendor/cm/prebuilt/common/etc/terminfo/a/aws:system/etc/terminfo/a/aws \
    vendor/cm/prebuilt/common/etc/terminfo/a/att610-w:system/etc/terminfo/a/att610-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/abm85h-old:system/etc/terminfo/a/abm85h-old \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-rv:system/etc/terminfo/a/avt-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5620-24:system/etc/terminfo/a/att5620-24 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+local:system/etc/terminfo/a/ansi+local \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-w-nl:system/etc/terminfo/a/att4415-w-nl \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-videx:system/etc/terminfo/a/apple-videx \
    vendor/cm/prebuilt/common/etc/terminfo/a/att505-24:system/etc/terminfo/a/att505-24 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+sgrbold:system/etc/terminfo/a/ansi+sgrbold \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-vm80:system/etc/terminfo/a/apple-vm80 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+sgrul:system/etc/terminfo/a/ansi+sgrul \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+local1:system/etc/terminfo/a/ansi+local1 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-26:system/etc/terminfo/a/aaa-26 \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-videx2:system/etc/terminfo/a/apple-videx2 \
    vendor/cm/prebuilt/common/etc/terminfo/a/ansi+sgr:system/etc/terminfo/a/ansi+sgr \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415+nl:system/etc/terminfo/a/att4415+nl \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-rv-unk:system/etc/terminfo/a/aaa-rv-unk \
    vendor/cm/prebuilt/common/etc/terminfo/a/amiga:system/etc/terminfo/a/amiga \
    vendor/cm/prebuilt/common/etc/terminfo/a/att505:system/etc/terminfo/a/att505 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att605-w:system/etc/terminfo/a/att605-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/att510a:system/etc/terminfo/a/att510a \
    vendor/cm/prebuilt/common/etc/terminfo/a/att730r-24:system/etc/terminfo/a/att730r-24 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att630-24:system/etc/terminfo/a/att630-24 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm2:system/etc/terminfo/a/adm2 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att730r:system/etc/terminfo/a/att730r \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4424-1:system/etc/terminfo/a/att4424-1 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-db:system/etc/terminfo/a/aaa-db \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4410:system/etc/terminfo/a/att4410 \
    vendor/cm/prebuilt/common/etc/terminfo/a/avatar0:system/etc/terminfo/a/avatar0 \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm31:system/etc/terminfo/a/adm31 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa:system/etc/terminfo/a/aaa \
    vendor/cm/prebuilt/common/etc/terminfo/a/ampex210:system/etc/terminfo/a/ampex210 \
    vendor/cm/prebuilt/common/etc/terminfo/a/avt-w-ns:system/etc/terminfo/a/avt-w-ns \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-36:system/etc/terminfo/a/aaa-36 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4424m:system/etc/terminfo/a/att4424m \
    vendor/cm/prebuilt/common/etc/terminfo/a/apollo_color:system/etc/terminfo/a/apollo_color \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-60-rv:system/etc/terminfo/a/aaa-60-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/adm20:system/etc/terminfo/a/adm20 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4415-rv:system/etc/terminfo/a/att4415-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/apple-videx3:system/etc/terminfo/a/apple-videx3 \
    vendor/cm/prebuilt/common/etc/terminfo/a/att5420_2-w:system/etc/terminfo/a/att5420_2-w \
    vendor/cm/prebuilt/common/etc/terminfo/a/att4418:system/etc/terminfo/a/att4418 \
    vendor/cm/prebuilt/common/etc/terminfo/a/aaa-48-rv:system/etc/terminfo/a/aaa-48-rv \
    vendor/cm/prebuilt/common/etc/terminfo/a/att610-103k:system/etc/terminfo/a/att610-103k \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy75-mc:system/etc/terminfo/w/wy75-mc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt-25-w:system/etc/terminfo/w/wy99gt-25-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-24:system/etc/terminfo/w/wy520-24 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-vb:system/etc/terminfo/w/wy520-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy185-wvb:system/etc/terminfo/w/wy185-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-vb:system/etc/terminfo/w/wy325-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-42-w:system/etc/terminfo/w/wy60-42-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy350-vb:system/etc/terminfo/w/wy350-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt-w-vb:system/etc/terminfo/w/wy99gt-w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy85-wvb:system/etc/terminfo/w/wy85-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy100:system/etc/terminfo/w/wy100 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-25:system/etc/terminfo/w/wy160-25 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy350-wvb:system/etc/terminfo/w/wy350-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy85-8bit:system/etc/terminfo/w/wy85-8bit \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-48:system/etc/terminfo/w/wy520-48 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy120-25:system/etc/terminfo/w/wy120-25 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325:system/etc/terminfo/w/wy325 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt-vb:system/etc/terminfo/w/wy99gt-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370:system/etc/terminfo/w/wy370 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-43-w:system/etc/terminfo/w/wy60-43-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-25-w:system/etc/terminfo/w/wy60-25-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wsvt25:system/etc/terminfo/w/wsvt25 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-36:system/etc/terminfo/w/wy520-36 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-48pc:system/etc/terminfo/w/wy520-48pc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy350:system/etc/terminfo/w/wy350 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-EPC:system/etc/terminfo/w/wy370-EPC \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-nk:system/etc/terminfo/w/wy370-nk \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-w:system/etc/terminfo/w/wy520-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-epc-24:system/etc/terminfo/w/wy520-epc-24 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-36pc:system/etc/terminfo/w/wy520-36pc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-25w:system/etc/terminfo/w/wy325-25w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy185-24:system/etc/terminfo/w/wy185-24 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-25-w:system/etc/terminfo/w/wy160-25-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy75-wvb:system/etc/terminfo/w/wy75-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy100q:system/etc/terminfo/w/wy100q \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-vb:system/etc/terminfo/w/wy160-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy185-w:system/etc/terminfo/w/wy185-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-vb:system/etc/terminfo/w/wy60-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy75-w:system/etc/terminfo/w/wy75-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-42-w:system/etc/terminfo/w/wy160-42-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy30:system/etc/terminfo/w/wy30 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy85:system/etc/terminfo/w/wy85 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99a-ansi:system/etc/terminfo/w/wy99a-ansi \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy75-vb:system/etc/terminfo/w/wy75-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy75:system/etc/terminfo/w/wy75 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy50-vb:system/etc/terminfo/w/wy50-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-25:system/etc/terminfo/w/wy60-25 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520:system/etc/terminfo/w/wy520 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy85-w:system/etc/terminfo/w/wy85-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy120-25-w:system/etc/terminfo/w/wy120-25-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-w:system/etc/terminfo/w/wy60-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-rv:system/etc/terminfo/w/wy370-rv \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-w-vb:system/etc/terminfo/w/wy325-w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy185-vb:system/etc/terminfo/w/wy185-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-epc-vb:system/etc/terminfo/w/wy520-epc-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy50-mc:system/etc/terminfo/w/wy50-mc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-wvb:system/etc/terminfo/w/wy370-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt-tek:system/etc/terminfo/w/wy99gt-tek \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-epc-wvb:system/etc/terminfo/w/wy520-epc-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-36w:system/etc/terminfo/w/wy520-36w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-42:system/etc/terminfo/w/wy60-42 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60:system/etc/terminfo/w/wy60 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy120-w-vb:system/etc/terminfo/w/wy120-w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-48w:system/etc/terminfo/w/wy520-48w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt-25:system/etc/terminfo/w/wy99gt-25 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99f:system/etc/terminfo/w/wy99f \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy50-wvb:system/etc/terminfo/w/wy50-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-48wpc:system/etc/terminfo/w/wy520-48wpc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-epc-w:system/etc/terminfo/w/wy520-epc-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy120:system/etc/terminfo/w/wy120 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-43w-vb:system/etc/terminfo/w/wy325-43w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-w:system/etc/terminfo/w/wy160-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy30-mc:system/etc/terminfo/w/wy30-mc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-tek:system/etc/terminfo/w/wy370-tek \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-w:system/etc/terminfo/w/wy325-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-42w-vb:system/etc/terminfo/w/wy325-42w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-42:system/etc/terminfo/w/wy325-42 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wsvt25m:system/etc/terminfo/w/wsvt25m \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy120-w:system/etc/terminfo/w/wy120-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-43:system/etc/terminfo/w/wy160-43 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-43:system/etc/terminfo/w/wy325-43 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-42w:system/etc/terminfo/w/wy325-42w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy120-vb:system/etc/terminfo/w/wy120-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy350-w:system/etc/terminfo/w/wy350-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-25:system/etc/terminfo/w/wy325-25 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-36wpc:system/etc/terminfo/w/wy520-36wpc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wsiris:system/etc/terminfo/w/wsiris \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy50-w:system/etc/terminfo/w/wy50-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99-ansi:system/etc/terminfo/w/wy99-ansi \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-wvb:system/etc/terminfo/w/wy520-wvb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-42:system/etc/terminfo/w/wy160-42 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy185:system/etc/terminfo/w/wy185 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99fa:system/etc/terminfo/w/wy99fa \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160:system/etc/terminfo/w/wy160 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt:system/etc/terminfo/w/wy99gt \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-w-vb:system/etc/terminfo/w/wy160-w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy520-epc:system/etc/terminfo/w/wy520-epc \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy325-43w:system/etc/terminfo/w/wy325-43w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy50:system/etc/terminfo/w/wy50 \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-105k:system/etc/terminfo/w/wy370-105k \
    vendor/cm/prebuilt/common/etc/terminfo/w/wyse-vp:system/etc/terminfo/w/wyse-vp \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy30-vb:system/etc/terminfo/w/wy30-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy85-vb:system/etc/terminfo/w/wy85-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-w-vb:system/etc/terminfo/w/wy60-w-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-w:system/etc/terminfo/w/wy370-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy99gt-w:system/etc/terminfo/w/wy99gt-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-43-w:system/etc/terminfo/w/wy160-43-w \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy160-tek:system/etc/terminfo/w/wy160-tek \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy75ap:system/etc/terminfo/w/wy75ap \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy370-vb:system/etc/terminfo/w/wy370-vb \
    vendor/cm/prebuilt/common/etc/terminfo/w/wy60-43:system/etc/terminfo/w/wy60-43 \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt200pp:system/etc/terminfo/n/ncr260vt200pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncsa-vt220:system/etc/terminfo/n/ncsa-vt220 \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt300an:system/etc/terminfo/n/ncr160vt300an \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy350wpp:system/etc/terminfo/n/ncr260wy350wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt300pp:system/etc/terminfo/n/ncr160vt300pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-old-unk:system/etc/terminfo/n/news-old-unk \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt300pp:system/etc/terminfo/n/ncr260vt300pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-unk:system/etc/terminfo/n/news-unk \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vppp:system/etc/terminfo/n/ncr260vppp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr7900i:system/etc/terminfo/n/ncr7900i \
    vendor/cm/prebuilt/common/etc/terminfo/n/newhpkeyboard:system/etc/terminfo/n/newhpkeyboard \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp512-o:system/etc/terminfo/n/nwp512-o \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160wy50+pp:system/etc/terminfo/n/ncr160wy50+pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp512:system/etc/terminfo/n/nwp512 \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-42:system/etc/terminfo/n/news-42 \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp517-w:system/etc/terminfo/n/nwp517-w \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260intwan:system/etc/terminfo/n/ncr260intwan \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260intwpp:system/etc/terminfo/n/ncr260intwpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260intan:system/etc/terminfo/n/ncr260intan \
    vendor/cm/prebuilt/common/etc/terminfo/n/news28:system/etc/terminfo/n/news28 \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp517:system/etc/terminfo/n/nwp517 \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy50+pp:system/etc/terminfo/n/ncr260wy50+pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt300an:system/etc/terminfo/n/ncr260vt300an \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160wy50+wpp:system/etc/terminfo/n/ncr160wy50+wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncsa-m-ns:system/etc/terminfo/n/ncsa-m-ns \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt200wpp:system/etc/terminfo/n/ncr260vt200wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt200wan:system/etc/terminfo/n/ncr160vt200wan \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160wy60pp:system/etc/terminfo/n/ncr160wy60pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr7900iv:system/etc/terminfo/n/ncr7900iv \
    vendor/cm/prebuilt/common/etc/terminfo/n/nextshell:system/etc/terminfo/n/nextshell \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt300wan:system/etc/terminfo/n/ncr160vt300wan \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt100pp:system/etc/terminfo/n/ncr260vt100pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncsa:system/etc/terminfo/n/ncsa \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt100pp:system/etc/terminfo/n/ncr160vt100pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy325pp:system/etc/terminfo/n/ncr260wy325pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/newhp:system/etc/terminfo/n/newhp \
    vendor/cm/prebuilt/common/etc/terminfo/n/news29:system/etc/terminfo/n/news29 \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncsa-m:system/etc/terminfo/n/ncsa-m \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vppp:system/etc/terminfo/n/ncr160vppp \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp513:system/etc/terminfo/n/nwp513 \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260intpp:system/etc/terminfo/n/ncr260intpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt100wpp:system/etc/terminfo/n/ncr260vt100wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt100wpp:system/etc/terminfo/n/ncr160vt100wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt200pp:system/etc/terminfo/n/ncr160vt200pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/nxterm:system/etc/terminfo/n/nxterm \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt100an:system/etc/terminfo/n/ncr260vt100an \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncsa-ns:system/etc/terminfo/n/ncsa-ns \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt100wan:system/etc/terminfo/n/ncr160vt100wan \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-42-sjis:system/etc/terminfo/n/news-42-sjis \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncrvt100wan:system/etc/terminfo/n/ncrvt100wan \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy50+wpp:system/etc/terminfo/n/ncr260wy50+wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt100an:system/etc/terminfo/n/ncr160vt100an \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-29:system/etc/terminfo/n/news-29 \
    vendor/cm/prebuilt/common/etc/terminfo/n/nansi.sysk:system/etc/terminfo/n/nansi.sysk \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp513-a:system/etc/terminfo/n/nwp513-a \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-29-sjis:system/etc/terminfo/n/news-29-sjis \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncrvt100an:system/etc/terminfo/n/ncrvt100an \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt300wpp:system/etc/terminfo/n/ncr160vt300wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy60wpp:system/etc/terminfo/n/ncr260wy60wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt200an:system/etc/terminfo/n/ncr160vt200an \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vt200wpp:system/etc/terminfo/n/ncr160vt200wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-29-euc:system/etc/terminfo/n/news-29-euc \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160vpwpp:system/etc/terminfo/n/ncr160vpwpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy350pp:system/etc/terminfo/n/ncr260wy350pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-33-euc:system/etc/terminfo/n/news-33-euc \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-33-sjis:system/etc/terminfo/n/news-33-sjis \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt200an:system/etc/terminfo/n/ncr260vt200an \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt300wan:system/etc/terminfo/n/ncr260vt300wan \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr160wy60wpp:system/etc/terminfo/n/ncr160wy60wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp513-o:system/etc/terminfo/n/nwp513-o \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr7901:system/etc/terminfo/n/ncr7901 \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-42-euc:system/etc/terminfo/n/news-42-euc \
    vendor/cm/prebuilt/common/etc/terminfo/n/next:system/etc/terminfo/n/next \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt200wan:system/etc/terminfo/n/ncr260vt200wan \
    vendor/cm/prebuilt/common/etc/terminfo/n/news-33:system/etc/terminfo/n/news-33 \
    vendor/cm/prebuilt/common/etc/terminfo/n/northstar:system/etc/terminfo/n/northstar \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp512-a:system/etc/terminfo/n/nwp512-a \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy60pp:system/etc/terminfo/n/ncr260wy60pp \
    vendor/cm/prebuilt/common/etc/terminfo/n/nwp511:system/etc/terminfo/n/nwp511 \
    vendor/cm/prebuilt/common/etc/terminfo/n/nansi.sys:system/etc/terminfo/n/nansi.sys \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vpwpp:system/etc/terminfo/n/ncr260vpwpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260wy325wpp:system/etc/terminfo/n/ncr260wy325wpp \
    vendor/cm/prebuilt/common/etc/terminfo/n/ncr260vt100wan:system/etc/terminfo/n/ncr260vt100wan \
    vendor/cm/prebuilt/common/etc/terminfo/k/kaypro:system/etc/terminfo/k/kaypro \
    vendor/cm/prebuilt/common/etc/terminfo/k/kt7ix:system/etc/terminfo/k/kt7ix \
    vendor/cm/prebuilt/common/etc/terminfo/k/klone+acs:system/etc/terminfo/k/klone+acs \
    vendor/cm/prebuilt/common/etc/terminfo/k/klone+sgr-dumb:system/etc/terminfo/k/klone+sgr-dumb \
    vendor/cm/prebuilt/common/etc/terminfo/k/klone+color:system/etc/terminfo/k/klone+color \
    vendor/cm/prebuilt/common/etc/terminfo/k/kterm:system/etc/terminfo/k/kterm \
    vendor/cm/prebuilt/common/etc/terminfo/k/kt7:system/etc/terminfo/k/kt7 \
    vendor/cm/prebuilt/common/etc/terminfo/k/klone+sgr:system/etc/terminfo/k/klone+sgr \
    vendor/cm/prebuilt/common/etc/terminfo/k/kermit:system/etc/terminfo/k/kermit \
    vendor/cm/prebuilt/common/etc/terminfo/k/kermit-am:system/etc/terminfo/k/kermit-am \
    vendor/cm/prebuilt/common/etc/terminfo/k/klone+koi8acs:system/etc/terminfo/k/klone+koi8acs \
    vendor/cm/prebuilt/common/etc/terminfo/s/superbee-xsb:system/etc/terminfo/s/superbee-xsb \
    vendor/cm/prebuilt/common/etc/terminfo/s/superbrain:system/etc/terminfo/s/superbrain \
    vendor/cm/prebuilt/common/etc/terminfo/s/sb:system/etc/terminfo/s/sb \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-il:system/etc/terminfo/s/sun-il \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-c:system/etc/terminfo/s/sun-c \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-ss5:system/etc/terminfo/s/sun-ss5 \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-s:system/etc/terminfo/s/sun-s \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-12:system/etc/terminfo/s/sun-12 \
    vendor/cm/prebuilt/common/etc/terminfo/s/soroc140:system/etc/terminfo/s/soroc140 \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-34:system/etc/terminfo/s/sun-34 \
    vendor/cm/prebuilt/common/etc/terminfo/s/st52:system/etc/terminfo/s/st52 \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-24:system/etc/terminfo/s/sun-24 \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-48:system/etc/terminfo/s/sun-48 \
    vendor/cm/prebuilt/common/etc/terminfo/s/scrhp:system/etc/terminfo/s/scrhp \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun:system/etc/terminfo/s/sun \
    vendor/cm/prebuilt/common/etc/terminfo/s/screen3:system/etc/terminfo/s/screen3 \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-1:system/etc/terminfo/s/sun-1 \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-e-s:system/etc/terminfo/s/sun-e-s \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-e:system/etc/terminfo/s/sun-e \
    vendor/cm/prebuilt/common/etc/terminfo/s/scoansi:system/etc/terminfo/s/scoansi \
    vendor/cm/prebuilt/common/etc/terminfo/s/soroc120:system/etc/terminfo/s/soroc120 \
    vendor/cm/prebuilt/common/etc/terminfo/s/simterm:system/etc/terminfo/s/simterm \
    vendor/cm/prebuilt/common/etc/terminfo/s/scanset:system/etc/terminfo/s/scanset \
    vendor/cm/prebuilt/common/etc/terminfo/s/sun-17:system/etc/terminfo/s/sun-17 \
    vendor/cm/prebuilt/common/etc/terminfo/s/screen2:system/etc/terminfo/s/screen2 \
    vendor/cm/prebuilt/common/etc/terminfo/s/screen:system/etc/terminfo/s/screen \
    vendor/cm/prebuilt/common/etc/terminfo/s/screen-w:system/etc/terminfo/s/screen-w \
    vendor/cm/prebuilt/common/etc/terminfo/s/sb2:system/etc/terminfo/s/sb2 \
    vendor/cm/prebuilt/common/etc/terminfo/s/superbeeic:system/etc/terminfo/s/superbeeic \
    vendor/cm/prebuilt/common/etc/terminfo/s/screwpoint:system/etc/terminfo/s/screwpoint \
    vendor/cm/prebuilt/common/etc/terminfo/s/sbi:system/etc/terminfo/s/sbi \
    vendor/cm/prebuilt/common/etc/terminfo/s/synertek:system/etc/terminfo/s/synertek \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-w-rv:system/etc/terminfo/b/bq300-w-rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bg1.25rv:system/etc/terminfo/b/bg1.25rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8-pc:system/etc/terminfo/b/bq300-8-pc \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8-pc-w:system/etc/terminfo/b/bq300-8-pc-w \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-pc-w-rv:system/etc/terminfo/b/bq300-pc-w-rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bg1.25nv:system/etc/terminfo/b/bg1.25nv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8-pc-w-rv:system/etc/terminfo/b/bq300-8-pc-w-rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/beehive3:system/etc/terminfo/b/beehive3 \
    vendor/cm/prebuilt/common/etc/terminfo/b/bsdos-sparc:system/etc/terminfo/b/bsdos-sparc \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8rv:system/etc/terminfo/b/bq300-8rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bg2.0rv:system/etc/terminfo/b/bg2.0rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-w:system/etc/terminfo/b/bq300-w \
    vendor/cm/prebuilt/common/etc/terminfo/b/bantam:system/etc/terminfo/b/bantam \
    vendor/cm/prebuilt/common/etc/terminfo/b/bsdos-pc:system/etc/terminfo/b/bsdos-pc \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8-pc-rv:system/etc/terminfo/b/bq300-8-pc-rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bitgraph:system/etc/terminfo/b/bitgraph \
    vendor/cm/prebuilt/common/etc/terminfo/b/bg1.25:system/etc/terminfo/b/bg1.25 \
    vendor/cm/prebuilt/common/etc/terminfo/b/basis:system/etc/terminfo/b/basis \
    vendor/cm/prebuilt/common/etc/terminfo/b/beehive:system/etc/terminfo/b/beehive \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-w-8rv:system/etc/terminfo/b/bq300-w-8rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/blit:system/etc/terminfo/b/blit \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-pc:system/etc/terminfo/b/bq300-pc \
    vendor/cm/prebuilt/common/etc/terminfo/b/beehive4:system/etc/terminfo/b/beehive4 \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-pc-rv:system/etc/terminfo/b/bq300-pc-rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bobcat:system/etc/terminfo/b/bobcat \
    vendor/cm/prebuilt/common/etc/terminfo/b/bg300-rv:system/etc/terminfo/b/bg300-rv \
    vendor/cm/prebuilt/common/etc/terminfo/b/bsdos-ppc:system/etc/terminfo/b/bsdos-ppc \
    vendor/cm/prebuilt/common/etc/terminfo/b/bsdos-pc-nobold:system/etc/terminfo/b/bsdos-pc-nobold \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8:system/etc/terminfo/b/bq300-8 \
    vendor/cm/prebuilt/common/etc/terminfo/b/beacon:system/etc/terminfo/b/beacon \
    vendor/cm/prebuilt/common/etc/terminfo/b/beterm:system/etc/terminfo/b/beterm \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-8w:system/etc/terminfo/b/bq300-8w \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300-pc-w:system/etc/terminfo/b/bq300-pc-w \
    vendor/cm/prebuilt/common/etc/terminfo/b/bq300:system/etc/terminfo/b/bq300 \
    vendor/cm/prebuilt/common/etc/terminfo/b/bg2.0:system/etc/terminfo/b/bg2.0 \
    vendor/cm/prebuilt/common/etc/terminfo/e/esprit-am:system/etc/terminfo/e/esprit-am \
    vendor/cm/prebuilt/common/etc/terminfo/e/ecma+sgr:system/etc/terminfo/e/ecma+sgr \
    vendor/cm/prebuilt/common/etc/terminfo/e/emu:system/etc/terminfo/e/emu \
    vendor/cm/prebuilt/common/etc/terminfo/e/excel62-rv:system/etc/terminfo/e/excel62-rv \
    vendor/cm/prebuilt/common/etc/terminfo/e/excel62-w:system/etc/terminfo/e/excel62-w \
    vendor/cm/prebuilt/common/etc/terminfo/e/ex155:system/etc/terminfo/e/ex155 \
    vendor/cm/prebuilt/common/etc/terminfo/e/env230:system/etc/terminfo/e/env230 \
    vendor/cm/prebuilt/common/etc/terminfo/e/ep48:system/etc/terminfo/e/ep48 \
    vendor/cm/prebuilt/common/etc/terminfo/e/eterm:system/etc/terminfo/e/eterm \
    vendor/cm/prebuilt/common/etc/terminfo/e/excel62:system/etc/terminfo/e/excel62 \
    vendor/cm/prebuilt/common/etc/terminfo/e/ergo4000:system/etc/terminfo/e/ergo4000 \
    vendor/cm/prebuilt/common/etc/terminfo/e/ep40:system/etc/terminfo/e/ep40 \
    vendor/cm/prebuilt/common/etc/terminfo/e/esprit:system/etc/terminfo/e/esprit \
    vendor/cm/prebuilt/common/etc/terminfo/e/ecma+color:system/etc/terminfo/e/ecma+color \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19-g:system/etc/terminfo/h/h19-g \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2640b:system/etc/terminfo/h/hp2640b \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+pfk+arrows:system/etc/terminfo/h/hp+pfk+arrows \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2397a:system/etc/terminfo/h/hp2397a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2627a:system/etc/terminfo/h/hp2627a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hft-c-old:system/etc/terminfo/h/hft-c-old \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1420:system/etc/terminfo/h/hz1420 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-48:system/etc/terminfo/h/hp2621-48 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1520:system/etc/terminfo/h/hz1520 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2624-10p:system/etc/terminfo/h/hp2624-10p \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1520-noesc:system/etc/terminfo/h/hz1520-noesc \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626-12:system/etc/terminfo/h/hp2626-12 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621p:system/etc/terminfo/h/hp2621p \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2623:system/etc/terminfo/h/hp2623 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp9845:system/etc/terminfo/h/hp9845 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hds200:system/etc/terminfo/h/hds200 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2392:system/etc/terminfo/h/hp2392 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621b:system/etc/terminfo/h/hp2621b \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2:system/etc/terminfo/h/hp2 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+pfk-cr:system/etc/terminfo/h/hp+pfk-cr \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2627c:system/etc/terminfo/h/hp2627c \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp110:system/etc/terminfo/h/hp110 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1500:system/etc/terminfo/h/hz1500 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+labels:system/etc/terminfo/h/hp+labels \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626-12x40:system/etc/terminfo/h/hp2626-12x40 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz2000:system/etc/terminfo/h/hz2000 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621:system/etc/terminfo/h/hp2621 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp300h:system/etc/terminfo/h/hp300h \
    vendor/cm/prebuilt/common/etc/terminfo/h/ha8675:system/etc/terminfo/h/ha8675 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2624b-p:system/etc/terminfo/h/hp2624b-p \
    vendor/cm/prebuilt/common/etc/terminfo/h/hft-c:system/etc/terminfo/h/hft-c \
    vendor/cm/prebuilt/common/etc/terminfo/h/hpgeneric:system/etc/terminfo/h/hpgeneric \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2624b-10p-p:system/etc/terminfo/h/hp2624b-10p-p \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1552:system/etc/terminfo/h/hz1552 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621b-kx-p:system/etc/terminfo/h/hp2621b-kx-p \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+pfk+cr:system/etc/terminfo/h/hp+pfk+cr \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19-us:system/etc/terminfo/h/h19-us \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-fl:system/etc/terminfo/h/hp2621-fl \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626-x40:system/etc/terminfo/h/hp2626-x40 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626-12-s:system/etc/terminfo/h/hp2626-12-s \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1000:system/etc/terminfo/h/hz1000 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621p-a:system/etc/terminfo/h/hp2621p-a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1552-rv:system/etc/terminfo/h/hz1552-rv \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626-ns:system/etc/terminfo/h/hp2626-ns \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+arrows:system/etc/terminfo/h/hp+arrows \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2627a-rev:system/etc/terminfo/h/hp2627a-rev \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp70092:system/etc/terminfo/h/hp70092 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2645:system/etc/terminfo/h/hp2645 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+printer:system/etc/terminfo/h/hp+printer \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp9837:system/etc/terminfo/h/hp9837 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hmod1:system/etc/terminfo/h/hmod1 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-ba:system/etc/terminfo/h/hp2621-ba \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp150:system/etc/terminfo/h/hp150 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-nl:system/etc/terminfo/h/hp2621-nl \
    vendor/cm/prebuilt/common/etc/terminfo/h/hirez100-w:system/etc/terminfo/h/hirez100-w \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2622:system/etc/terminfo/h/hp2622 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2640a:system/etc/terminfo/h/hp2640a \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19:system/etc/terminfo/h/h19 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hft:system/etc/terminfo/h/hft \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp98550:system/etc/terminfo/h/hp98550 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp236:system/etc/terminfo/h/hp236 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2382a:system/etc/terminfo/h/hp2382a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hz1510:system/etc/terminfo/h/hz1510 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626-s:system/etc/terminfo/h/hp2626-s \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2648:system/etc/terminfo/h/hp2648 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2624:system/etc/terminfo/h/hp2624 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2626:system/etc/terminfo/h/hp2626 \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19-u:system/etc/terminfo/h/h19-u \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp262x:system/etc/terminfo/h/hp262x \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19-a:system/etc/terminfo/h/h19-a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp700-wy:system/etc/terminfo/h/hp700-wy \
    vendor/cm/prebuilt/common/etc/terminfo/h/hpansi:system/etc/terminfo/h/hpansi \
    vendor/cm/prebuilt/common/etc/terminfo/h/hpex:system/etc/terminfo/h/hpex \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2641a:system/etc/terminfo/h/hp2641a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-k45:system/etc/terminfo/h/hp2621-k45 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hazel:system/etc/terminfo/h/hazel \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19-bs:system/etc/terminfo/h/h19-bs \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621b-kx:system/etc/terminfo/h/hp2621b-kx \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621b-p:system/etc/terminfo/h/hp2621b-p \
    vendor/cm/prebuilt/common/etc/terminfo/h/hpterm:system/etc/terminfo/h/hpterm \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-a:system/etc/terminfo/h/hp2621-a \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp+color:system/etc/terminfo/h/hp+color \
    vendor/cm/prebuilt/common/etc/terminfo/h/hirez100:system/etc/terminfo/h/hirez100 \
    vendor/cm/prebuilt/common/etc/terminfo/h/ha8686:system/etc/terminfo/h/ha8686 \
    vendor/cm/prebuilt/common/etc/terminfo/h/hp2621-nt:system/etc/terminfo/h/hp2621-nt \
    vendor/cm/prebuilt/common/etc/terminfo/h/h19k:system/etc/terminfo/h/h19k \
    vendor/cm/prebuilt/common/etc/terminfo/h/hpsub:system/etc/terminfo/h/hpsub \
    vendor/cm/prebuilt/common/etc/terminfo/z/zen30:system/etc/terminfo/z/zen30 \
    vendor/cm/prebuilt/common/etc/terminfo/z/z29a-nkc-bc:system/etc/terminfo/z/z29a-nkc-bc \
    vendor/cm/prebuilt/common/etc/terminfo/z/z100:system/etc/terminfo/z/z100 \
    vendor/cm/prebuilt/common/etc/terminfo/z/z29:system/etc/terminfo/z/z29 \
    vendor/cm/prebuilt/common/etc/terminfo/z/z29a-nkc-uc:system/etc/terminfo/z/z29a-nkc-uc \
    vendor/cm/prebuilt/common/etc/terminfo/z/z29a-kc-uc:system/etc/terminfo/z/z29a-kc-uc \
    vendor/cm/prebuilt/common/etc/terminfo/z/z39-a:system/etc/terminfo/z/z39-a \
    vendor/cm/prebuilt/common/etc/terminfo/z/zen50:system/etc/terminfo/z/zen50 \
    vendor/cm/prebuilt/common/etc/terminfo/z/z340:system/etc/terminfo/z/z340 \
    vendor/cm/prebuilt/common/etc/terminfo/z/z340-nam:system/etc/terminfo/z/z340-nam \
    vendor/cm/prebuilt/common/etc/terminfo/z/z100bw:system/etc/terminfo/z/z100bw \
    vendor/cm/prebuilt/common/etc/terminfo/z/z29a:system/etc/terminfo/z/z29a \
    vendor/cm/prebuilt/common/etc/terminfo/z/ztx:system/etc/terminfo/z/ztx \
    vendor/cm/prebuilt/common/etc/terminfo/r/rxvt:system/etc/terminfo/r/rxvt \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent:system/etc/terminfo/r/regent \
    vendor/cm/prebuilt/common/etc/terminfo/r/rt6221:system/etc/terminfo/r/rt6221 \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent40:system/etc/terminfo/r/regent40 \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent100:system/etc/terminfo/r/regent100 \
    vendor/cm/prebuilt/common/etc/terminfo/r/rbcomm-nam:system/etc/terminfo/r/rbcomm-nam \
    vendor/cm/prebuilt/common/etc/terminfo/r/rcons-color:system/etc/terminfo/r/rcons-color \
    vendor/cm/prebuilt/common/etc/terminfo/r/rca:system/etc/terminfo/r/rca \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent60:system/etc/terminfo/r/regent60 \
    vendor/cm/prebuilt/common/etc/terminfo/r/rt6221-w:system/etc/terminfo/r/rt6221-w \
    vendor/cm/prebuilt/common/etc/terminfo/r/rxvt-color:system/etc/terminfo/r/rxvt-color \
    vendor/cm/prebuilt/common/etc/terminfo/r/rtpc:system/etc/terminfo/r/rtpc \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent25:system/etc/terminfo/r/regent25 \
    vendor/cm/prebuilt/common/etc/terminfo/r/rbcomm:system/etc/terminfo/r/rbcomm \
    vendor/cm/prebuilt/common/etc/terminfo/r/rbcomm-w:system/etc/terminfo/r/rbcomm-w \
    vendor/cm/prebuilt/common/etc/terminfo/r/rcons:system/etc/terminfo/r/rcons \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent20:system/etc/terminfo/r/regent20 \
    vendor/cm/prebuilt/common/etc/terminfo/r/regent40+:system/etc/terminfo/r/regent40+ \
    vendor/cm/prebuilt/common/etc/terminfo/m/msk227am:system/etc/terminfo/m/msk227am \
    vendor/cm/prebuilt/common/etc/terminfo/m/minix-old:system/etc/terminfo/m/minix-old \
    vendor/cm/prebuilt/common/etc/terminfo/m/modgraph48:system/etc/terminfo/m/modgraph48 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime-fb:system/etc/terminfo/m/mime-fb \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime314:system/etc/terminfo/m/mime314 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mt4520-rv:system/etc/terminfo/m/mt4520-rv \
    vendor/cm/prebuilt/common/etc/terminfo/m/masscomp1:system/etc/terminfo/m/masscomp1 \
    vendor/cm/prebuilt/common/etc/terminfo/m/microb:system/etc/terminfo/m/microb \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime3ax:system/etc/terminfo/m/mime3ax \
    vendor/cm/prebuilt/common/etc/terminfo/m/msk22714:system/etc/terminfo/m/msk22714 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime2a:system/etc/terminfo/m/mime2a \
    vendor/cm/prebuilt/common/etc/terminfo/m/masscomp:system/etc/terminfo/m/masscomp \
    vendor/cm/prebuilt/common/etc/terminfo/m/m2-nam:system/etc/terminfo/m/m2-nam \
    vendor/cm/prebuilt/common/etc/terminfo/m/mach-bold:system/etc/terminfo/m/mach-bold \
    vendor/cm/prebuilt/common/etc/terminfo/m/mt70:system/etc/terminfo/m/mt70 \
    vendor/cm/prebuilt/common/etc/terminfo/m/memhp:system/etc/terminfo/m/memhp \
    vendor/cm/prebuilt/common/etc/terminfo/m/ms-vt100:system/etc/terminfo/m/ms-vt100 \
    vendor/cm/prebuilt/common/etc/terminfo/m/minitel1b:system/etc/terminfo/m/minitel1b \
    vendor/cm/prebuilt/common/etc/terminfo/m/minix-old-am:system/etc/terminfo/m/minix-old-am \
    vendor/cm/prebuilt/common/etc/terminfo/m/modgraph2:system/etc/terminfo/m/modgraph2 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime3a:system/etc/terminfo/m/mime3a \
    vendor/cm/prebuilt/common/etc/terminfo/m/mm340:system/etc/terminfo/m/mm340 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mgr-sun:system/etc/terminfo/m/mgr-sun \
    vendor/cm/prebuilt/common/etc/terminfo/m/masscomp2:system/etc/terminfo/m/masscomp2 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mac:system/etc/terminfo/m/mac \
    vendor/cm/prebuilt/common/etc/terminfo/m/minitel1:system/etc/terminfo/m/minitel1 \
    vendor/cm/prebuilt/common/etc/terminfo/m/minitel1b-80:system/etc/terminfo/m/minitel1b-80 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mgr:system/etc/terminfo/m/mgr \
    vendor/cm/prebuilt/common/etc/terminfo/m/minix:system/etc/terminfo/m/minix \
    vendor/cm/prebuilt/common/etc/terminfo/m/mono-emx:system/etc/terminfo/m/mono-emx \
    vendor/cm/prebuilt/common/etc/terminfo/m/mai:system/etc/terminfo/m/mai \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime:system/etc/terminfo/m/mime \
    vendor/cm/prebuilt/common/etc/terminfo/m/modgraph:system/etc/terminfo/m/modgraph \
    vendor/cm/prebuilt/common/etc/terminfo/m/mac-w:system/etc/terminfo/m/mac-w \
    vendor/cm/prebuilt/common/etc/terminfo/m/mach:system/etc/terminfo/m/mach \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime2a-s:system/etc/terminfo/m/mime2a-s \
    vendor/cm/prebuilt/common/etc/terminfo/m/msk227:system/etc/terminfo/m/msk227 \
    vendor/cm/prebuilt/common/etc/terminfo/m/mgr-linux:system/etc/terminfo/m/mgr-linux \
    vendor/cm/prebuilt/common/etc/terminfo/m/mime-hb:system/etc/terminfo/m/mime-hb \
    vendor/cm/prebuilt/common/etc/terminfo/m/megatek:system/etc/terminfo/m/megatek \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt203-25-w:system/etc/terminfo/q/qvt203-25-w \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt119+-25-w:system/etc/terminfo/q/qvt119+-25-w \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt101+:system/etc/terminfo/q/qvt101+ \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt119+:system/etc/terminfo/q/qvt119+ \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt119+-w:system/etc/terminfo/q/qvt119+-w \
    vendor/cm/prebuilt/common/etc/terminfo/q/qnxt2:system/etc/terminfo/q/qnxt2 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt103:system/etc/terminfo/q/qvt103 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt203-25:system/etc/terminfo/q/qvt203-25 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt102:system/etc/terminfo/q/qvt102 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt203:system/etc/terminfo/q/qvt203 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt119+-25:system/etc/terminfo/q/qvt119+-25 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt101:system/etc/terminfo/q/qvt101 \
    vendor/cm/prebuilt/common/etc/terminfo/q/qdss:system/etc/terminfo/q/qdss \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt203-w:system/etc/terminfo/q/qvt203-w \
    vendor/cm/prebuilt/common/etc/terminfo/q/qnx:system/etc/terminfo/q/qnx \
    vendor/cm/prebuilt/common/etc/terminfo/q/qvt103-w:system/etc/terminfo/q/qvt103-w \
    vendor/cm/prebuilt/common/etc/terminfo/N/NCR260VT300WPP:system/etc/terminfo/N/NCR260VT300WPP \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm6154:system/etc/terminfo/i/ibm6154 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm8512:system/etc/terminfo/i/ibm8512 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm6155:system/etc/terminfo/i/ibm6155 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmvga:system/etc/terminfo/i/ibmvga \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm8514-c:system/etc/terminfo/i/ibm8514-c \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmega:system/etc/terminfo/i/ibmega \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm3161-C:system/etc/terminfo/i/ibm3161-C \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm3162:system/etc/terminfo/i/ibm3162 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm-pc:system/etc/terminfo/i/ibm-pc \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmmono:system/etc/terminfo/i/ibmmono \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmega-c:system/etc/terminfo/i/ibmega-c \
    vendor/cm/prebuilt/common/etc/terminfo/i/infoton:system/etc/terminfo/i/infoton \
    vendor/cm/prebuilt/common/etc/terminfo/i/icl6404-w:system/etc/terminfo/i/icl6404-w \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibcs2:system/etc/terminfo/i/ibcs2 \
    vendor/cm/prebuilt/common/etc/terminfo/i/icl6404:system/etc/terminfo/i/icl6404 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm5154:system/etc/terminfo/i/ibm5154 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ims950-b:system/etc/terminfo/i/ims950-b \
    vendor/cm/prebuilt/common/etc/terminfo/i/ims950-rv:system/etc/terminfo/i/ims950-rv \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmapa8c:system/etc/terminfo/i/ibmapa8c \
    vendor/cm/prebuilt/common/etc/terminfo/i/intext:system/etc/terminfo/i/intext \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm3151:system/etc/terminfo/i/ibm3151 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm5081-c:system/etc/terminfo/i/ibm5081-c \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm3161:system/etc/terminfo/i/ibm3161 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm6153-40:system/etc/terminfo/i/ibm6153-40 \
    vendor/cm/prebuilt/common/etc/terminfo/i/intext2:system/etc/terminfo/i/intext2 \
    vendor/cm/prebuilt/common/etc/terminfo/i/intertube2:system/etc/terminfo/i/intertube2 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmapa8c-c:system/etc/terminfo/i/ibmapa8c-c \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm327x:system/etc/terminfo/i/ibm327x \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm8503:system/etc/terminfo/i/ibm8503 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm6153-90:system/etc/terminfo/i/ibm6153-90 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ims-ansi:system/etc/terminfo/i/ims-ansi \
    vendor/cm/prebuilt/common/etc/terminfo/i/iris-ansi:system/etc/terminfo/i/iris-ansi \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmpcx:system/etc/terminfo/i/ibmpcx \
    vendor/cm/prebuilt/common/etc/terminfo/i/ifmr:system/etc/terminfo/i/ifmr \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm3101:system/etc/terminfo/i/ibm3101 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm5081:system/etc/terminfo/i/ibm5081 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm5151:system/etc/terminfo/i/ibm5151 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmpc3:system/etc/terminfo/i/ibmpc3 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm-apl:system/etc/terminfo/i/ibm-apl \
    vendor/cm/prebuilt/common/etc/terminfo/i/i400:system/etc/terminfo/i/i400 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ims950:system/etc/terminfo/i/ims950 \
    vendor/cm/prebuilt/common/etc/terminfo/i/iris-color:system/etc/terminfo/i/iris-color \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmvga-c:system/etc/terminfo/i/ibmvga-c \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm3164:system/etc/terminfo/i/ibm3164 \
    vendor/cm/prebuilt/common/etc/terminfo/i/intertube:system/etc/terminfo/i/intertube \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmaed:system/etc/terminfo/i/ibmaed \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm-system1:system/etc/terminfo/i/ibm-system1 \
    vendor/cm/prebuilt/common/etc/terminfo/i/i100:system/etc/terminfo/i/i100 \
    vendor/cm/prebuilt/common/etc/terminfo/i/iris-ansi-ap:system/etc/terminfo/i/iris-ansi-ap \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm6153:system/etc/terminfo/i/ibm6153 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibm8514:system/etc/terminfo/i/ibm8514 \
    vendor/cm/prebuilt/common/etc/terminfo/i/ibmpc:system/etc/terminfo/i/ibmpc \
    vendor/cm/prebuilt/common/etc/terminfo/o/oblit:system/etc/terminfo/o/oblit \
    vendor/cm/prebuilt/common/etc/terminfo/o/osborne:system/etc/terminfo/o/osborne \
    vendor/cm/prebuilt/common/etc/terminfo/o/osexec:system/etc/terminfo/o/osexec \
    vendor/cm/prebuilt/common/etc/terminfo/o/osborne-w:system/etc/terminfo/o/osborne-w \
    vendor/cm/prebuilt/common/etc/terminfo/o/oldsun:system/etc/terminfo/o/oldsun \
    vendor/cm/prebuilt/common/etc/terminfo/o/ofcons:system/etc/terminfo/o/ofcons \
    vendor/cm/prebuilt/common/etc/terminfo/o/origpc3:system/etc/terminfo/o/origpc3 \
    vendor/cm/prebuilt/common/etc/terminfo/o/oc100:system/etc/terminfo/o/oc100 \
    vendor/cm/prebuilt/common/etc/terminfo/o/oldpc3:system/etc/terminfo/o/oldpc3 \
    vendor/cm/prebuilt/common/etc/terminfo/o/opus3n1+:system/etc/terminfo/o/opus3n1+ \
    vendor/cm/prebuilt/common/etc/terminfo/o/otek4115:system/etc/terminfo/o/otek4115 \
    vendor/cm/prebuilt/common/etc/terminfo/o/omron:system/etc/terminfo/o/omron \
    vendor/cm/prebuilt/common/etc/terminfo/o/owl:system/etc/terminfo/o/owl \
    vendor/cm/prebuilt/common/etc/terminfo/o/otek4112:system/etc/terminfo/o/otek4112
