#!/bin/bash

#
# Get the version number from the tag in git and the number of commits as the build number
#
git=`sh /etc/profile; which git`
appVersion=$(git describe --tags --always --abbrev=0)
appBuild=$(git describe --long | cut -f 2 -d "-") 
gitHash=$(git describe --long | cut -f 3 -d "-")
echo "From GIT Version = $appVersion Build = $appBuild"

sed -e 's/${version}/'$appVersion'/' -e 's/${build}/'$appBuild'/' Scripts/Version.template > Sources/Research/Version.swift
