#!/bin/sh

## global variables
MAKE=make
MAKE_FLAGS=-j8

## user customizable variables. 
SDK_VERSION=8.1
TARGET_NAME=ChatDemo-UI2.0

ROOT=.
DIST=dist
BUILD=build
PAYLOAD=Payload

# ${1}: such as emclient-ios
# ${2}: such as Debug or Release
SDK_PROJECT_ROOT_SHORT=${1}
MODE=${2}
if [ -z ${SDK_PROJECT_ROOT_SHORT} ]; then
	SDK_PROJECT_ROOT_SHORT=emclient-ios
fi
if [ -z ${MODE} ]; then
	MODE=Release
fi

BUILD_DIR=${ROOT}/${BUILD}/${MODE}-iphoneos
TARGET_DIR=${BUILD_DIR}/${TARGET_NAME}.app

## clean 
rm -rf ${ROOT}/${BUILD}
rm -rf ${ROOT}/${PAYLOAD}
rm -rf ${ROOT}/${DIST}
mkdir ${ROOT}/${DIST}

## prepare sdk directory
sh ${ROOT}/preparesdk.sh ${SDK_PROJECT_ROOT_SHORT} ${MODE}

## make 
${MAKE} ${MAKE_FLAGS} target_name=${TARGET_NAME} sdk_version=${SDK_VERSION} configuration=${MODE}
ERROR=$?
if [ $ERROR -gt 0 ]; then
	echo 'Failed to build project!' 'target_name='${TARGET_NAME} 'sdk_version='${SDK_VERSION} 'configuration='${MODE}
    exit $ERROR
fi

## create dist directory
mkdir -p ${ROOT}/${PAYLOAD}
cp -r ${TARGET_DIR} ${ROOT}/${PAYLOAD}

## make ipa
zip -r ${ROOT}/${TARGET_NAME}.zip ${ROOT}/${PAYLOAD}
mv ${ROOT}/${TARGET_NAME}.zip ${ROOT}/${DIST}/${TARGET_NAME}.ipa

## zip dSYM
cp -r ${TARGET_DIR}.dSYM ${ROOT}/${DIST}/${TARGET_NAME}.dSYM
zip -r ${ROOT}/${DIST}/${TARGET_NAME}.dSYM.zip ${ROOT}/${DIST}/${TARGET_NAME}.dSYM
rm -rf ${ROOT}/${DIST}/${TARGET_NAME}.dSYM

## delete Payload directory
rm -rf ${ROOT}/${PAYLOAD}

## write version info
GIT_REVISION="`git rev-list HEAD -n 1`"
GIT_BRANCH="`git rev-parse --abbrev-ref HEAD`"
VERSION_INFO="`date '+%Y%m%d'`_`date '+%H%M%S'`_${GIT_BRANCH}_${GIT_REVISION}"
touch ${ROOT}/${DIST}/${VERSION_INFO}.txt
echo "Version Information: "
echo ${VERSION_INFO}
