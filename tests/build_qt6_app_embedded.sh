#!/bin/bash

# Build Qt 6 Test Application with Embedded QtWebDriver
#
# This script builds the Qt 6 test application with QtWebDriver embedded
# following the approach described in:
# https://github.com/cisco-open-source/qtwebdriver/wiki/Use-QtWebDriver-to-run-your-application

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WD_BUILD="$REPO_ROOT/out/desktop/release/Default"

echo "================================================"
echo "Qt 6 Test Application with Embedded QtWebDriver"
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

# Get Qt paths
if command -v qmake6 &> /dev/null; then
    QT_VERSION=$(qmake6 -query QT_VERSION)
    QT_INSTALL_BINS=$(qmake6 -query QT_INSTALL_BINS)
    QT_INSTALL_LIBS=$(qmake6 -query QT_INSTALL_LIBS)
    QT_INSTALL_HEADERS=$(qmake6 -query QT_INSTALL_HEADERS)
    QT_INSTALL_LIBEXECS=$(qmake6 -query QT_INSTALL_LIBEXECS)
    echo "Found Qt version: $QT_VERSION"
elif pkg-config --exists Qt6Core; then
    QT_VERSION=$(pkg-config --modversion Qt6Core)
    QT_INSTALL_LIBS=$(pkg-config --variable=libdir Qt6Core)
    QT_INSTALL_HEADERS=$(pkg-config --variable=includedir Qt6Core)
    echo "Found Qt version: $QT_VERSION"
    # Try to find libexec
    QT_INSTALL_LIBEXECS="/usr/lib/qt6/libexec"
    if [ ! -d "$QT_INSTALL_LIBEXECS" ]; then
        QT_INSTALL_LIBEXECS="/usr/lib/x86_64-linux-gnu/qt6/libexec"
    fi
else
    echo "Error: Could not detect Qt 6"
    exit 1
fi

echo "Qt paths:"
echo "  Headers: $QT_INSTALL_HEADERS"
echo "  Libraries: $QT_INSTALL_LIBS"
echo "  Libexec: $QT_INSTALL_LIBEXECS"
echo ""

# Check if QtWebDriver has been built
if [ ! -d "$WD_BUILD" ]; then
    echo "Error: QtWebDriver has not been built yet"
    echo ""
    echo "Please build QtWebDriver first:"
    echo "  1. Create a Qt 6 configuration: cp qt6_sample_config.gypi wd_config.gypi"
    echo "  2. Edit wd_config.gypi with your Qt 6 paths"
    echo "  3. Run: ./build.sh"
    echo ""
    exit 1
fi

# Check for required libraries
REQUIRED_LIBS=(
    "libWebDriver_core.a"
    "libWebDriver_extension_qt_base.a"
    "libchromium_base.a"
)

echo "Checking for QtWebDriver libraries..."
for lib in "${REQUIRED_LIBS[@]}"; do
    if [ ! -f "$WD_BUILD/$lib" ]; then
        echo "Error: Required library not found: $lib"
        echo "Please build QtWebDriver with Qt 6 support first"
        exit 1
    fi
    echo "  ✓ Found $lib"
done
echo ""

# Generate moc file
echo "Generating moc file..."
cd "$SCRIPT_DIR"
if [ -f "$QT_INSTALL_LIBEXECS/moc" ]; then
    "$QT_INSTALL_LIBEXECS/moc" qt6_test_app.cpp -o qt6_test_app.moc
else
    moc qt6_test_app.cpp -o qt6_test_app.moc
fi

if [ $? -ne 0 ]; then
    echo "Error: moc generation failed"
    exit 1
fi
echo "  ✓ Generated qt6_test_app.moc"
echo ""

# Compile with QtWebDriver support
echo "Compiling with QtWebDriver embedded..."
g++ -std=c++17 -fPIC \
    -Dtypeof=__typeof__ \
    -D_GLIBCXX_USE_C99_STDINT_TR1 \
    -Wno-error \
    -fpermissive \
    -DOS_POSIX \
    -DOS_LINUX \
    -DWD_ENABLE_WEB_VIEW=0 \
    -DQT_NO_SAMPLES \
    -DQT_NO_QML \
    -I"$QT_INSTALL_HEADERS" \
    -I"$QT_INSTALL_HEADERS/QtCore" \
    -I"$QT_INSTALL_HEADERS/QtGui" \
    -I"$QT_INSTALL_HEADERS/QtWidgets" \
    -I"$QT_INSTALL_HEADERS/QtNetwork" \
    -I"$QT_INSTALL_HEADERS/QtConcurrent" \
    -I"$REPO_ROOT/inc" \
    -I"$REPO_ROOT/inc/base" \
    -I"$REPO_ROOT/inc/commands" \
    -I"$REPO_ROOT/inc/extension_qt" \
    -I"$REPO_ROOT/inc/build" \
    -I"$REPO_ROOT/src/webdriver" \
    qt6_test_app.cpp \
    -o qt6_test_app_embedded \
    -L"$QT_INSTALL_LIBS" \
    -L"$WD_BUILD" \
    "$WD_BUILD/libWebDriver_core.a" \
    "$WD_BUILD/libWebDriver_extension_qt_base.a" \
    "$WD_BUILD/libchromium_base.a" \
    -lQt6Core \
    -lQt6Gui \
    -lQt6Widgets \
    -lQt6Network \
    -lpthread \
    -ldl \
    -Wl,-rpath,"$QT_INSTALL_LIBS"

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "Build successful!"
    echo "================================================"
    echo ""
    echo "Executable: $SCRIPT_DIR/qt6_test_app_embedded"
    echo ""
    echo "To run the application with embedded QtWebDriver:"
    echo "  $SCRIPT_DIR/qt6_test_app_embedded --port=9517"
    echo ""
    echo "The QtWebDriver server will start automatically on the specified port."
    echo "You can then connect with Selenium/WebDriver clients."
    echo ""
else
    echo ""
    echo "Build failed!"
    echo ""
    echo "If you encounter compilation errors, this may be due to known"
    echo "Qt 6 compatibility issues. See tests/QT6_INTEGRATION_FINDINGS.md"
    echo "for details and potential workarounds."
    exit 1
fi
