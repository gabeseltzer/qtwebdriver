#!/bin/sh

# QtWebDriver macOS CMake Build Script
# This script has been updated to use CMake instead of GYP

export QT_DIR=${QT_DIR:-/usr/local/opt/qt}
export PATH=$QT_DIR/bin:$PATH

echo "Generating version info..."
python3 generate_wdversion.py

# Create build directory
BUILD_DIR="out/mac/release"
mkdir -p "$BUILD_DIR"

echo "Configuring with CMake..."
cd "$BUILD_DIR" || exit 1

cmake ../../.. \
    -G Xcode \
    -DCMAKE_BUILD_TYPE=Release \
    -DQT_VERSION=6 \
    -DCMAKE_PREFIX_PATH="$QT_DIR" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed"
    exit 1
fi

if [ "$1" == "-all" ]; then
    echo "Building all targets..."
    xcodebuild -project QtWebDriver.xcodeproj -alltargets -configuration Release
else
    echo "Project configured. To build, run:"
    echo "  cd $BUILD_DIR"
    echo "  xcodebuild -project QtWebDriver.xcodeproj -alltargets -configuration Release"
    echo "Or open the Xcode project:"
    echo "  open $BUILD_DIR/QtWebDriver.xcodeproj"
fi
