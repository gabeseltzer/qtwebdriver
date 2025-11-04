#!/bin/bash

# Build script for Qt 6 test application

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"

echo "================================================"
echo "Qt 6 Test Application Build Script"
echo "================================================"
echo ""

# Check if Qt 6 is installed
if ! command -v qmake6 &> /dev/null && ! pkg-config --exists Qt6Core; then
    echo "Error: Qt 6 is not installed or not found in PATH"
    echo "Please install Qt 6 development packages:"
    echo "  Ubuntu/Debian: sudo apt-get install qt6-base-dev"
    echo "  Fedora: sudo dnf install qt6-qtbase-devel"
    echo "  Arch: sudo pacman -S qt6-base"
    exit 1
fi

# Check Qt 6 version
if command -v qmake6 &> /dev/null; then
    QT_VERSION=$(qmake6 -query QT_VERSION)
    echo "Found Qt version: $QT_VERSION"
elif pkg-config --exists Qt6Core; then
    QT_VERSION=$(pkg-config --modversion Qt6Core)
    echo "Found Qt version: $QT_VERSION"
fi

echo ""

# Create build directory
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning existing build directory..."
    rm -rf "$BUILD_DIR"
fi

echo "Creating build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo ""
echo "Running CMake configuration..."
cmake ..

if [ $? -ne 0 ]; then
    echo ""
    echo "Error: CMake configuration failed"
    exit 1
fi

echo ""
echo "Building application..."
make

if [ $? -ne 0 ]; then
    echo ""
    echo "Error: Build failed"
    exit 1
fi

echo ""
echo "================================================"
echo "Build successful!"
echo "================================================"
echo ""
echo "Executable: $BUILD_DIR/qt6_test_app"
echo ""
echo "To run the application:"
echo "  $BUILD_DIR/qt6_test_app"
echo ""
echo "To use with QtWebDriver:"
echo "  1. Start QtWebDriver server: ./WebDriver --port=9517"
echo "  2. Run this test app: $BUILD_DIR/qt6_test_app"
echo "  3. Connect with Selenium/WebDriver client on port 9517"
echo ""
