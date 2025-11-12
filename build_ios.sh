#!/bin/sh

# QtWebDriver iOS CMake Build Script
# This script has been updated to use CMake instead of GYP

export QT_DIR=${QT_DIR:-/usr/local/opt/qt6_ios}
export PATH=$QT_DIR/bin:$PATH

echo "Generating version info..."
python3 generate_wdversion.py

# Create build directory
BUILD_DIR="out/ios/release"
mkdir -p "$BUILD_DIR"

echo "Configuring with CMake for iOS..."
cd "$BUILD_DIR" || exit 1

cmake ../../.. \
    -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
    -DCMAKE_IOS_INSTALL_COMBINED=YES \
    -DCMAKE_BUILD_TYPE=Release \
    -DQT_VERSION=6 \
    -DCMAKE_PREFIX_PATH="$QT_DIR" \
    -DWD_CONFIG_WEBKIT=OFF \
    -DWD_CONFIG_QUICK=ON \
    -DIOS=ON

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed"
    exit 1
fi

if [ "$1" == "-all" ]; then
    echo "Building for iOS Simulator..."
    
    # Build individual targets for iOS
    xcodebuild -project QtWebDriver.xcodeproj -target chromium_base \
        -arch x86_64 -sdk iphonesimulator clean build
    
    xcodebuild -project QtWebDriver.xcodeproj -target WebDriver_core \
        -arch x86_64 -sdk iphonesimulator clean build
    
    xcodebuild -project QtWebDriver.xcodeproj -target WebDriver_extension_qt_base \
        -arch x86_64 -sdk iphonesimulator clean build
    
    xcodebuild -project QtWebDriver.xcodeproj -target WebDriver_extension_qt_quick \
        -arch x86_64 -sdk iphonesimulator clean build
    
    echo "Build completed. Check out/ios/release for binaries."
else
    echo "Project configured for iOS. To build, run:"
    echo "  cd $BUILD_DIR"
    echo "  xcodebuild -project QtWebDriver.xcodeproj -target <target> -sdk iphonesimulator"
    echo "Or open the Xcode project:"
    echo "  open $BUILD_DIR/QtWebDriver.xcodeproj"
fi
