ifeq ($(WITH_GMS),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
else
GAPPS_VARIANT := pico
$(call inherit-product-if-exists, vendor/google/build/opengapps-packages.mk)
endif
