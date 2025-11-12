#!/bin/bash

# Build Qt Test Application with Embedded QtWebDriver

QT_PATH=/opt/qt/6.8.2/gcc_64
WD_ROOT=/workspaces/qtwebdriver
WD_BUILD=$WD_ROOT/out/desktop/release/Default

echo "Building Qt Test Application with Embedded QtWebDriver..."
echo "Qt path: $QT_PATH"
echo "WebDriver root: $WD_ROOT"

# Set Qt environment
export PATH=$QT_PATH/bin:$PATH
export LD_LIBRARY_PATH=$QT_PATH/lib:$LD_LIBRARY_PATH

# Generate moc file
echo "Running moc..."
$QT_PATH/libexec/moc test_qt_app.cpp -o test_qt_app.moc

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
    -I$WD_ROOT/inc/build \
    -I$WD_ROOT/src/webdriver \
    test_qt_app.cpp \
    -o test_qt_app \
    -L$QT_PATH/lib \
    -L$WD_BUILD \
    $WD_BUILD/libWebDriver_core.a \
    $WD_BUILD/libWebDriver_extension_qt_base.a \
    $WD_BUILD/libtest_widgets.a \
    $WD_BUILD/libchromium_base.a \
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
