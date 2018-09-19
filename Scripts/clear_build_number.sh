#!/bin/sh
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0" "${PRODUCT_SETTINGS_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 0" "${PRODUCT_SETTINGS_PATH}"
/usr/libexec/PlistBuddy -c "Set :GITHash abcdef" "${PRODUCT_SETTINGS_PATH}"
echo "Cleared build number in ${PRODUCT_SETTINGS_PATH}"
