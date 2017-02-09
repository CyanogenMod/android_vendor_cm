# GSM APN list
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/etc/apns-conf.xml:system/etc/apns-conf.xml

PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/etc/selective-spn-conf.xml:system/etc/selective-spn-conf.xml

# SIM Toolkit
PRODUCT_PACKAGES += \
    Stk
