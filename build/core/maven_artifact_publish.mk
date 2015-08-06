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

full_target := $(call doc-timestamp-for,$(LOCAL_MODULE))

ifeq ($(strip $(LOCAL_MAVEN_GROUP_ID)),)
  $(error LOCAL_MAVEN_GROUP not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_ARTIFACT_ID)),)
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

$(full_target): repoId := $(LOCAL_MAVEN_REPO_ID)
$(full_target): repo := $(LOCAL_MAVEN_REPO)
$(full_target): group := $(LOCAL_MAVEN_GROUP_ID)
$(full_target): artifact := $(LOCAL_MAVEN_ARTIFACT_ID)
$(full_target): version := $(LOCAL_MAVEN_VERSION)
$(full_target): packaging := $(LOCAL_MAVEN_PACKAGING)
$(full_target): path_to_file := $(LOCAL_MAVEN_FILE_PATH)

$(info $(full_target))

$(full_target):
	$(hide) mvn -e deploy:deploy-file
			-DgroupId=$(group) \
			-DartifactId=$(artifact) \
			-Dversion=$(version) \
			-Dpackaging=$(packaging) \
			-Dfile=$(path_to_file) \
			-DrepositoryId=$(repoId) \
			-Durl=$(repo) \
			-DgeneratePom=true
	@echo -e ${CL_GRN}"Publishing:"${CL_RST}" $@"

PUBLISH_MAVEN_PREBUILT += $(full_target)

$(LOCAL_MODULE) : $(full_target)