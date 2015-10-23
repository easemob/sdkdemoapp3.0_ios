#!/bin/sh

## global variables
MAKE=make
MAKE_FLAGS=-j8
SDK_PROJECT_ROOT_SHORT=${1}
MODE=${2}

DEMO_ROOT=.
SDK_DIR=EaseMobSDK
SDK_ROOT=${DEMO_ROOT}/../${SDK_DIR}

# debug
#echo "SDK_ROOT -> " ${SDK_ROOT}

SDK_PROJECT=${SDK_PROJECT_ROOT_SHORT}/EaseMobClientSDK/export
SDK_PROJECT_ROOT=${DEMO_ROOT}/../../${SDK_PROJECT}

# debug
#echo "SDK_PROJECT -> " ${SDK_PROJECT}
#echo "SDK_PROJECT_ROOT -> " ${SDK_PROJECT_ROOT}

if [ ! -d "${SDK_ROOT}" ]; then
	mkdir ${SDK_ROOT}
	mkdir ${SDK_ROOT}/lib
	cp -r -p ${SDK_PROJECT_ROOT}/include ${SDK_ROOT}
	cp -r -p ${SDK_PROJECT_ROOT}/resources ${SDK_ROOT}
	cp ${SDK_PROJECT_ROOT}/lib/fat/${MODE}/libEaseMobClientSDK.a ${SDK_ROOT}/lib
	cp ${SDK_PROJECT_ROOT}/lib/fat/${MODE}/libEaseMobClientSDKLite.a ${SDK_ROOT}/lib
	cp ${SDK_PROJECT_ROOT}/lib/fat/${MODE}/libCallService.a ${SDK_ROOT}/lib
else
	# debug
	echo "no need to prepare sdk package."
fi

