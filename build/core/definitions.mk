#
# CM-specific macros
#
define uniq
$(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
endef

# Resolve the required module name to 32-bit or 64-bit variant.
# Get a list of corresponding 32-bit module names, if one exists.
# From build/core/main.mk
define get-32-bit-modules
$(strip $(foreach m,$(1),\
  $(if $(ALL_MODULES.$(m)$(TARGET_2ND_ARCH_MODULE_SUFFIX).CLASS),\
    $(m)$(TARGET_2ND_ARCH_MODULE_SUFFIX))))
endef

define get-proprietary-dependencies-path
$(strip $(foreach m,$(1),\
  $(foreach p,$(ALL_MODULES.$(m).REQUIRED),\
    $(foreach mk,$(ALL_MODULES.$(p).MAKEFILE),\
      $(if $(filter $(2)/%,$(mk)),\
        $(p))))))
endef

define get-proprietary-dependencies
$(call get-proprietary-dependencies-path,$(1),vendor)
endef

# Generate the list of proprietary files installed for the required modules
define get-proprietary-files-list
$(eval p_p := $(1))\
$(eval p_p += $(call get-32-bit-modules,$(1)))\
$(eval p_p_d := $(call get-proprietary-dependencies,$(p_p)))\
$(eval p :=)\
$(foreach _p,$(call uniq,$(p_p) $(p_p_d)),\
  $(foreach mk,$(ALL_MODULES.$(_p).MAKEFILE),\
    $(if $(filter vendor/%,$(mk)),\
       $(eval p += $(_p)))))\
$(strip $(patsubst $(TARGET_OUT)/%,%,\
  $(filter $(TARGET_OUT)/%,$(call module-installed-files,$(p)))))
endef
