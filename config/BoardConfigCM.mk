# Charger
ifneq ($(WITH_CM_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.cm
endif

ifeq ($(TARGET_USES_SEPARATE_CACHE_PARTITION),true)
  ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.has.cache.partition=1
else
  ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.has.cache.partition=0
endif
