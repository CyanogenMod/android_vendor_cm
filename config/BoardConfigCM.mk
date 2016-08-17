# Charger
ifneq ($(WITH_CM_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.cm
    BOARD_SEPOLICY_DIRS += vendor/cm/charger/sepolicy
endif
