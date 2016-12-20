# World APN list
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

# Telephony packages
PRODUCT_PACKAGES += \
    messaging \
    Stk \
    CellBroadcastReceiver

# Default ringtone
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=Orion.ogg

# IMS Default Permission
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/qcom_ims.xml:system/etc/default-permissions/qcom_ims.xml
