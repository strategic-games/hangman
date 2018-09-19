#!/bin/sh
#
# Get the version number from the tag in git and the number of commits as the build number
#
git=`sh /etc/profile; which git`
appVersion=$(git describe --tags --always --abbrev=0)
appBuild=$(git describe --long | cut -f 2 -d "-") 
gitHash=$(git describe --long | cut -f 3 -d "-")
echo "From GIT Version = $appVersion Build = $appBuild"

#
# Set the version info in plist file
#
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $appVersion" "${PRODUCT_SETTINGS_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $appBuild" "${PRODUCT_SETTINGS_PATH}"
/usr/libexec/PlistBuddy -c "Set :GITHash $gitHash" "${PRODUCT_SETTINGS_PATH}"
echo "Updated ${PRODUCT_SETTINGS_PATH}"
