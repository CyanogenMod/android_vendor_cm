#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifeq ($(shell command -v convert),)
  $(info **********************************************)
  $(info The boot animation could not be generated as)
  $(info ImageMagick is not installed in your system.)
  $(info $(space))
  $(info Please install ImageMagick from this website:)
  $(info https://imagemagick.org/script/binary-releases.php)
  $(info **********************************************)
  $(error stop)
endif

define build-bootanimation
    sh vendor/cm/bootanimation/generate-bootanimation.sh \
    $(TARGET_SCREEN_WIDTH) \
    $(TARGET_SCREEN_HEIGHT) \
    $(TARGET_BOOTANIMATION_HALF_RES)
endef

TARGET_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_BOOTANIMATION):
	$(build-bootanimation)

PRODUCT_BOOTANIMATION := $(TARGET_OUT)/media/bootanimation.zip
$(PRODUCT_BOOTANIMATION) : $(TARGET_BOOTANIMATION) | $(ACP)
	$(transform-prebuilt-to-target)

ALL_PREBUILT += $(PRODUCT_BOOTANIMATION)

.PHONY: cmbootanimation
cmbootanimation: $(PRODUCT_BOOTANIMATION)
