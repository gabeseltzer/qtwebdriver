#!/bin/bash

# Build Qt Test Application with Embedded QtWebDriver (CMake version)

QT_PATH=${QT_PATH:-/opt/qt/6.8.2/gcc_64}
WD_ROOT=${WD_ROOT:-/workspaces/qtwebdriver}
BUILD_DIR=${BUILD_DIR:-$WD_ROOT/build}

echo "Building Qt Test Application with Embedded QtWebDriver..."
echo "Qt path: $QT_PATH"
echo "WebDriver root: $WD_ROOT"
echo "Build directory: $BUILD_DIR"

# Find the actual library directory (VSCode CMake extension uses nested directories)
LIB_DIR=""
if [ -f "$BUILD_DIR/lib/libWebDriver_core.a" ]; then
    LIB_DIR="$BUILD_DIR/lib"
else
    # Search for libraries in VSCode CMake extension build directories
    FOUND_LIB=$(find "$BUILD_DIR" -name "libWebDriver_core.a" -type f 2>/dev/null | head -1)
    if [ -n "$FOUND_LIB" ]; then
        LIB_DIR=$(dirname "$FOUND_LIB")
        echo "Found libraries in: $LIB_DIR"
    fi
fi

# Verify libraries exist
if [ -z "$LIB_DIR" ] || [ ! -f "$LIB_DIR/libWebDriver_core.a" ]; then
    echo "Error: QtWebDriver libraries not found"
    echo "Please build QtWebDriver first using VSCode CMake extension or run:"
    echo "  cd $WD_ROOT && ./build.sh"
    exit 1
fi

# Set Qt environment
export PATH=$QT_PATH/bin:$PATH
export LD_LIBRARY_PATH=$QT_PATH/lib:$LD_LIBRARY_PATH

# Determine moc location
if [ -f "$QT_PATH/libexec/moc" ]; then
    MOC_PATH="$QT_PATH/libexec/moc"
elif [ -f "$QT_PATH/bin/moc" ]; then
    MOC_PATH="$QT_PATH/bin/moc"
else
    echo "Error: moc not found in $QT_PATH"
    exit 1
fi

# Generate moc file
echo "Running moc..."
$MOC_PATH test_qt_app.cpp -o test_qt_app.moc

# Compile with QtWebDriver support
echo "Compiling with QtWebDriver libraries..."
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
    -I$QT_PATH/include \
    -I$QT_PATH/include/QtCore \
    -I$QT_PATH/include/QtGui \
    -I$QT_PATH/include/QtWidgets \
    -I$QT_PATH/include/QtNetwork \
    -I$QT_PATH/include/QtConcurrent \
    -I$WD_ROOT/inc \
    -I$WD_ROOT/inc/commands \
    -I$WD_ROOT/inc/extension_qt \
    -I$WD_ROOT/src/webdriver \
    test_qt_app.cpp \
    -o test_qt_app \
    -L"$QT_PATH/lib" \
    -L"$LIB_DIR" \
    "$LIB_DIR/libWebDriver_core.a" \
    "$LIB_DIR/libWebDriver_extension_qt_base.a" \
    "$LIB_DIR/libtest_widgets.a" \
    "$LIB_DIR/libchromium_base.a" \
    -lQt6Core \
    -lQt6Gui \
    -lQt6Widgets \
    -lQt6Network \
    -lpthread \
    -Wl,-rpath,$QT_PATH/lib

if [ $? -eq 0 ]; then
    echo "Build successful! Binary: ./test_qt_app"
    echo "To run: ./test_qt_app --port=9517"
else
    echo "Build failed!"
    exit 1
fi
