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

# Makefile for producing cmsdk jdiff reports.
# Run "make cmsdk-jdiff-html" in the $ANDROID_BUILD_TOP directory.

jdiff_out := $(HOST_OUT)/cmsdk-jdiff

# Validate against previous release platform sdk version api text within prebuilts
cm_last_released_sdk_version := $(shell echo ${CM_PLATFORM_SDK_VERSION}-1 | bc)

current_text_description := $(CM_SRC_API_DIR)/$(CM_PLATFORM_SDK_VERSION).txt
current_api_xml_description := $(jdiff_out)/api-current.xml
$(current_api_xml_description) : $(current_text_description) $(APICHECK)
	$(hide) echo "Converting API file to XML: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(APICHECK_COMMAND) -convert2xml $< $@

previous_text_description := $(CM_SRC_API_DIR)/$(cm_last_released_sdk_version).txt
previous_api_xml_description := $(jdiff)/api-previous.xml
$(previous_api_xml_description) : $(previous_text_description) $(APICHECK)
	$(hide) echo "Converting API file to XML: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(APICHECK_COMMAND) -convert2xml $< $@

# cmsdk-jdiff := $(jdiff_out)/api-previous.html
cmsdk-jdiff : $(current_api_xml_description) $(previous_api_xml_description)

cmsdk_tests_apk := $(call intermediates-dir-for,APPS,CMPlatformTests)/package.apk

.PHONY: cmsdk-jdiff-html
cmsdk-jdiff-html : $(cmsdk-jdiff)
