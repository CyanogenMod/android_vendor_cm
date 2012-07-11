# Inherit common CM stuff
$(call inherit-product, vendor/cm/config/common.mk)

# Bring in all video files
$(call inherit-product, frameworks/base/data/videos/VideoPackage2.mk)

# Include CM audio files
include vendor/cm/config/cm_audio.mk

# Default ringtone
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=CyanTone.ogg \
    ro.config.notification_sound=CyanMessage.ogg \
    ro.config.alarm_alert=CyanAlarm.ogg

PRODUCT_PACKAGES += \
  Mms

ifeq ($(TARGET_BOOTANIMATION_NAME),)
    PRODUCT_COPY_FILES += \
        vendor/cm/prebuilt/common/bootanimation/vertical-480x800.zip:system/media/bootanimation.zip
endif
