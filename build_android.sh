#!/usr/bin/env bash

# QtWebDriver Android CMake Build Script
# This script has been updated to use CMake instead of GYP

archs=$1

if [ -z "$QT_DIR" ]; then
    export QT_DIR=/opt/Qt6/6.5.0
fi

export QT_VERSION=${QT_VERSION:-6.5.0}
export ANDROID_PACKAGE=org.webdriver.qt
export ANDROID_APP_NAME=AndroidWD

if [ -z "$archs" ]; then
    archs="arm64-v8a x86_64"
fi

if [ -z "$ANDROID_NDK_ROOT" ]; then
    export ANDROID_NDK_ROOT=/opt/android/ndk/latest
fi

if [ -z "$ANDROID_SDK_ROOT" ]; then
    export ANDROID_SDK_ROOT=/opt/android/sdk
fi

for arch in $archs
do
    echo "####################### Building for $arch #######################"
    
    # Set architecture-specific variables
    case "$arch" in
        arm64-v8a)
            ANDROID_ABI="arm64-v8a"
            QT_ANDROID_DIR="$QT_DIR/android_arm64_v8a"
            ;;
        armeabi-v7a)
            ANDROID_ABI="armeabi-v7a"
            QT_ANDROID_DIR="$QT_DIR/android_armv7"
            ;;
        x86_64)
            ANDROID_ABI="x86_64"
            QT_ANDROID_DIR="$QT_DIR/android_x86_64"
            ;;
        x86)
            ANDROID_ABI="x86"
            QT_ANDROID_DIR="$QT_DIR/android_x86"
            ;;
        *)
            echo "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    # Generate version info
    python3 generate_wdversion.py
    
    # Create build directory
    BUILD_DIR="out/android_${arch}/release"
    mkdir -p "$BUILD_DIR"
    
    echo "Configuring with CMake for Android $arch..."
    cd "$BUILD_DIR" || exit 1
    
    cmake ../../.. \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_ANDROID_NDK="$ANDROID_NDK_ROOT" \
        -DCMAKE_ANDROID_ARCH_ABI="$ANDROID_ABI" \
        -DCMAKE_ANDROID_STL_TYPE=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DQT_VERSION=6 \
        -DCMAKE_PREFIX_PATH="$QT_ANDROID_DIR" \
        -DCMAKE_FIND_ROOT_PATH="$QT_ANDROID_DIR" \
        -DQT_HOST_PATH="$QT_DIR/gcc_64" \
        -DANDROID=ON \
        -DWD_CONFIG_WEBKIT=OFF \
        -DWD_CONFIG_QUICK=ON
    
    if [ $? -ne 0 ]; then
        echo "ERROR: CMake configuration failed for $arch"
        exit 1
    fi
    
    # Build
    echo "Building for $arch..."
    cmake --build . --parallel $(nproc)
    
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        echo "####################### Build $arch failed !!! #######################"
        exit $RETVAL
    fi
    
    echo "####################### Build $arch completed successfully #######################"
    
    cd - > /dev/null
done

echo "All Android builds completed successfully!"
echo "Check out/android_*/release/ directories for build artifacts"
