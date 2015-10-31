PROJECT_NAME="ChatDemo-UI2.0.xcodeproj"
CC=xcodebuild
TARGET_NAME=${target_name}
SDK_VERSION=${sdk_ver}
CONFIGURATION=${configuration}
DEVICE_ARCHS="armv7 armv7s arm64"

all:compile

compile:
	echo target=${TARGET_NAME} configuration=${CONFIGURATION} project=${PROJECT_NAME} sdk=iphoneos${SDK_VERSION} ARCHS=${DEVICE_ARCHS}
	${CC} -target ${TARGET_NAME} -configuration ${CONFIGURATION} -project ${PROJECT_NAME} -sdk iphoneos${SDK_VERSION} ARCHS=${DEVICE_ARCHS} VALID_ARCHS=${DEVICE_ARCHS}

clean:
	echo target=${TARGET_NAME} configuration=${CONFIGURATION} project=${PROJECT_NAME} sdk=iphoneos${SDK_VERSION}
	${CC} clean -target ${TARGET_NAME} -configuration ${CONFIGURATION} -sdk iphoneos${SDK_VERSION} -project ${PROJECT_NAME}
