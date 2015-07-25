# Copyright (C) 2015 The CyanogenMod Project
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

ifeq ($(strip $(LOCAL_MAVEN_GROUP)),)
  $(error LOCAL_MAVEN_GROUP not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_ARTIFACT)),)
  $(error LOCAL_MAVEN_ARTIFACT not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_VERSION)),)
  $(error LOCAL_MAVEN_VERSION not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_REPO)),)
  $(error LOCAL_MAVEN_REPO not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_PACKAGING)),)
  LOCAL_MAVEN_PACKAGING := jar
endif

artifact_filename := $(LOCAL_MAVEN_GROUP).$(LOCAL_MAVEN_ARTIFACT)-$(LOCAL_MAVEN_VERSION)$(if $(LOCAL_MAVEN_CLASSIFIER),-$(LOCAL_MAVEN_CLASSIFIER)).$(LOCAL_MAVEN_PACKAGING)

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/$(artifact_filename)

$(LOCAL_PREBUILT_MODULE_FILE): repo := $(LOCAL_MAVEN_REPO)
$(LOCAL_PREBUILT_MODULE_FILE): group := $(LOCAL_MAVEN_GROUP)
$(LOCAL_PREBUILT_MODULE_FILE): artifact := $(LOCAL_MAVEN_ARTIFACT)
$(LOCAL_PREBUILT_MODULE_FILE): version := $(LOCAL_MAVEN_VERSION)
$(LOCAL_PREBUILT_MODULE_FILE): packaging := $(LOCAL_MAVEN_PACKAGING)
$(LOCAL_PREBUILT_MODULE_FILE): classifier := $(LOCAL_MAVEN_CLASSIFIER)
$(LOCAL_PREBUILT_MODULE_FILE): nogroup_file := $(artifact)-$(version)$(if $(classifier),-$(classifier)).$(packaging)

$(LOCAL_PREBUILT_MODULE_FILE):
ifeq ($(shell mvn --version | head -1),Apache Maven 3.0.5)
	$(hide) mvn -q dependency:get \
		-DrepoUrl=$(repo) \
		-DgroupId=$(group) \
		-DartifactId=$(artifact) \
		-Dversion=$(version) \
		-Dpackaging=$(packaging) \
		-Dclassifier=$(classifier) \
		-Dtransitive=false
	$(hide) mkdir -p $(dir $@)
	$(hide) cp ~/.m2/repository/$(subst .,/,$(group))/$(artifact)/$(version)/$(nogroup_file) $(dir $@)
	$(hide) mv $(dir $@)/$(nogroup_file) $@ 2>/dev/null || true
else
	$(hide) mvn -q dependency:get dependency:copy \
		-DremoteRepositories=central::::$(repo) \
		-Dartifact=$(group):$(artifact):$(version):$(packaging)$(if $(classifier),:$(classifier)) \
		-Dmdep.prependGroupId=true \
		-Dmdep.overWriteSnapshots=true \
		-Dmdep.overWriteReleases=true \
		-Dtransitive=false \
		-DoutputDirectory=$(dir $@)
endif
	@echo -e ${CL_GRN}"Download:"${CL_RST}" $@"

include $(BUILD_PREBUILT)

# the "fetchprebuilts" target will go through and pre-download all of the maven dependencies in the tree
fetchprebuilts: $(LOCAL_PREBUILT_MODULE_FILE)