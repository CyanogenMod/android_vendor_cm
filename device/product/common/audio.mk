# Audio
PRODUCT_PACKAGES += \
    audio.a2dp.default \
    audio.primary.$(TARGET_BOARD_PLATFORM) \
    audio_policy.$(TARGET_BOARD_PLATFORM) \
    audio.r_submix.default \
    audio.usb.default \
    tinymix

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:system/etc/permissions/android.software.midi.xml
