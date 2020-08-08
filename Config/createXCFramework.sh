#! /bin/sh -e

FRAMEWORK="XNLogger"
PROJECT_DIR=$(cd .. && pwd)
OUTPUT_DIR=$(cd .. && pwd)/build/XCFramework

echo "▸ Cleaning the dir: ${OUTPUT_DIR}"
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

archivePathSimulator() {
  local DIR=${OUTPUT_DIR}/Archives/"${1}-SIMULATOR"
  echo "${DIR}"
}

archivePathDevice() {
  local DIR=${OUTPUT_DIR}/Archives/"${1}-DEVICE"
  echo "${DIR}"
}

# Archive takes 3 params
#
# 1st == SCHEME
# 2nd == destination
# 3rd == archivePath
archive() {
    echo "▸ Starts archiving the scheme: ${1} for destination: ${2};\n▸ Archive path: ${3}.xcarchive"
    xcodebuild archive \
    -workspace $PROJECT_DIR/$FRAMEWORK.xcworkspace \
    -scheme ${1} \
    -destination "${2}" \
    -archivePath "${3}" \
    -configuration "Release" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
}

# Builds archive for iOS simulator & device
buildArchive() {
  local SCHEME=${1}

  archive $SCHEME "generic/platform=iOS Simulator" $(archivePathSimulator $SCHEME)
  archive $SCHEME "generic/platform=iOS" $(archivePathDevice $SCHEME)
}

# Creates xc framework
createXCFramework() {
  local FRAMEWORK_ARCHIVE_PATH_POSTFIX=".xcarchive/Products/Library/Frameworks"
  local FRAMEWORK_SIMULATOR_DIR="$(archivePathSimulator $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"
  local FRAMEWORK_DEVICE_DIR="$(archivePathDevice $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"

  xcodebuild -create-xcframework \
            -framework ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework \
            -framework ${FRAMEWORK_DEVICE_DIR}/${1}.framework \
            -output ${OUTPUT_DIR}/Products/${1}.xcframework
}

#### Dynamic Framework ####

DYNAMIC_FRAMEWORK=$FRAMEWORK

echo "▸ Archive $DYNAMIC_FRAMEWORK"
buildArchive ${DYNAMIC_FRAMEWORK}

echo "▸ Create $DYNAMIC_FRAMEWORK.xcframework"
createXCFramework ${DYNAMIC_FRAMEWORK}

echo "▸ Cleaning intermediate products"
rm -rf "${OUTPUT_DIR}/Archives"
