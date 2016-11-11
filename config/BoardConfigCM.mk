# Charger
ifneq ($(WITH_CM_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.cm
endif

ifeq ($(BOARD_CACHEIMAGE_PARTITION_SIZE),)
  ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.has.cache.partition=0
else
  ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.has.cache.partition=1
endif
