#
# This policy configuration will be used by all products that
# inherit from CM
#

BOARD_SEPOLICY_DIRS := \
    vendor/cm/sepolicy

BOARD_SEPOLICY_REPLACE := \
    mac_permissions.xml

BOARD_SEPOLICY_UNION := \
    adbd.te \
    bluetooth.te \
    sdcardd.te \
    system.te \
    surfaceflinger.te \
    zygote.te \
    seapp_contexts \
    file_contexts
