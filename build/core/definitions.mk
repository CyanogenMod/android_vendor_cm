#
# CM-specific macros
#
define uniq
$(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
endef

# $(1): Path to makefile, relative to $(TOP), like device/foo/bar/BoardConfig.mk
# $(2): Name of variable, like TARGET_ARCH
define get-variable-from-makefile
$(shell MAKEFILE_FOR_VALUE="$(1)" $(MAKE) -f vendor/cm/build/get-variable-from-makefile.mk value-from-makefile-$(2))
endef

# Wrapper for get-variable-from-makefile
# Boardconfig inclusion from build/core/envsetup.mk
# $(1): Name of variable, like TARGET_ARCH
define get-variable-from-boardconfig
$(eval board_config_mk := \
        $(strip $(wildcard \
                $(SRC_TARGET_DIR)/board/$(TARGET_DEVICE)/BoardConfig.mk \
                $(shell test -d device && find device -maxdepth 4 -path '*/$(TARGET_DEVICE)/BoardConfig.mk') \
                $(shell test -d vendor && find vendor -maxdepth 4 -path '*/$(TARGET_DEVICE)/BoardConfig.mk') \
        )))
$(if $(board_config_mk),,\
  $(error No config file found for TARGET_DEVICE $(TARGET_DEVICE)))
$(if ($(words $(board_config_mk)),1),,\
  $(error Multiple board config files for TARGET_DEVICE $(TARGET_DEVICE): $(board_config_mk)))
$(call get-variable-from-makefile,$(board_config_mk),$(1))
endef
