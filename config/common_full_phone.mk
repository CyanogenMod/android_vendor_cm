# Inherit common Bliss stuff
$(call inherit-product, vendor/bliss/config/common_full.mk)

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Io.ogg \
    ro.config.alarm_alert=CyanAlarm.ogg

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/bliss/prebuilt/common/bootanimation/480.zip:system/media/bootanimation.zip
endif

$(call inherit-product, vendor/bliss/config/telephony.mk)
