#!/bin/bash

v=$1

if [ -e "~/.m2/repository/org/cyanogenmod/gello/$v/gello-$v.apk" ]; then
  rm -rf ~/.m2/repository/org/cyanogenmod/gello
  mkdir -p ~/.m2/repository/org/cyanogenmod/gello/$v
  for f in gello-$v.apk gello-$v.apk.md5 gello-$v.apk.sha1; do
    wget --no-check-certificate https://maven.cyanogenmod.org/artifactory/gello_prebuilds/org/cyanogenmod/gello/$v/$f -O ~/.m2/repository/org/cyanogenmod/gello/$v/$f
  done
fi
