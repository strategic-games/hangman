#!/usr/bin/env bash

PACKAGE_NAME=`echo "$EXECUTABLE_NAME" | sed "s/ /_/g"`
IDENTIFIER="de.tamaracha.${PACKAGE_NAME}"
APP_VERSION=$(git describe --tags --always --abbrev=0)

pkgbuild --root "${DSTROOT}" \
--identifier "${IDENTIFIER}" \
--version "$APP_VERSION" \
--install-location "/" \
"/tmp/${PACKAGE_NAME}-${APP_VERSION}.pkg"
