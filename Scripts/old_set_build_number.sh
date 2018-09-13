#!/bin/sh
# ---------------------------- IMPORTANT ----------------------------
# You must set GITHash to something like 'Set by build script' in the file
# file '<Project Name>-Info.plist' in the 'Supporting Files' group
# -------------------------------------------------------------------
#
# Get the version number from the tag in git and the number of commits as the build number
#
appVersion=$(git describe --tags --always --abbrev=0)
appBuild=$(git describe --long | cut -f 2 -d "-") 
gitHash=$(git describe --long | cut -f 3 -d "-")
echo "From GIT Version = $appVersion Build = $appBuild"

#touch $INFOPLIST_FILE
#
# Set the version info in plist file
#
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $appVersion" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $appBuild" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :GITHash $gitHash" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
echo "Updated ${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
