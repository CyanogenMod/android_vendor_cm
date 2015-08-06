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
ifeq ($(strip $(LOCAL_MAVEN_FILE_PATH)),)
  $(error LOCAL_MAVEN_FILE_PATH not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_REPO_ID)),)
  $(error LOCAL_MAVEN_REPO_ID not defined.)
endif

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/$(artifact_filename)

$(LOCAL_PREBUILT_MODULE_FILE): repoId := $(LOCAL_MAVEN_REPO_ID)
$(LOCAL_PREBUILT_MODULE_FILE): repo := $(LOCAL_MAVEN_REPO)
$(LOCAL_PREBUILT_MODULE_FILE): group := $(LOCAL_MAVEN_GROUP)
$(LOCAL_PREBUILT_MODULE_FILE): artifact := $(LOCAL_MAVEN_ARTIFACT)
$(LOCAL_PREBUILT_MODULE_FILE): version := $(LOCAL_MAVEN_VERSION)
$(LOCAL_PREBUILT_MODULE_FILE): packaging := $(LOCAL_MAVEN_PACKAGING)
$(LOCAL_PREBUILT_MODULE_FILE): classifier := $(LOCAL_MAVEN_CLASSIFIER)
$(LOCAL_PREBUILT_MODULE_FILE): path_to_file := $(LOCAL_MAVEN_FILE_PATH)
$(LOCAL_PREBUILT_MODULE_FILE):
    $(hide) mvn -e org.apache.maven.plugins:maven-dependency-plugin:2.10:deploy-file \
            -DgroupId=$(group) \
            -DartifactId=$(artifact) \
            -Dversion=$(version) \
            -Dpackaging=$(packaging) \
            -Dfile=$(path_to_file) \
            -DrepositoryId=$(repo) \
            -Durl=http://www-test.icts.uiowa.edu/artifactory/libs-release-local \
            -DgeneratePom=true
	@echo -e ${CL_GRN}"Publishing:"${CL_RST}" $@"

include $(BUILD_PREBUILT)
