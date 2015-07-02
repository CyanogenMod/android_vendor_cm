#
# CM-specific macros
#
define uniq
$(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
endef

# $(1): Path to makefile, relative to $(TOP), like device/foo/bar/BoardConfig.mk
# $(2): Name of variable, like TARGET_ARCH
define get-variable-from-makefile
$(shell MAKEFILE_FOR_VALUE=$(1) $(MAKE) -f vendor/cm/build/get-variable-from-makefile.mk value-from-makefile-$(2))
endef
