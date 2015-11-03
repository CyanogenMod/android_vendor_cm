# Inherit common CM stuff
$(call inherit-product, vendor/cm/config/common.mk)

# Include CM audio files
include vendor/cm/config/cm_audio.mk

# Live wallpapers
PRODUCT_PACKAGES += \
    Galaxy4 \
    HoloSpiralWallpaper \
    LiveWallpapers \
    LiveWallpapersPicker \
    MagicSmokeWallpapers \
    NoiseField \
    PhaseBeam \
    PhotoTable \
    PhotoPhase

# Extra tools in CM
PRODUCT_PACKAGES += \
    vim \
    zip \
    unrar \
    curl
