#!/bin/bash

# Build Qt Test Application

QT_PATH=/opt/qt/6.8.2/gcc_64

echo "Building Qt Test Application..."
echo "Qt path: $QT_PATH"

# Set Qt environment
export PATH=$QT_PATH/bin:$PATH
export LD_LIBRARY_PATH=$QT_PATH/lib:$LD_LIBRARY_PATH

# Generate moc file
echo "Running moc..."
$QT_PATH/libexec/moc test_qt_app.cpp -o test_qt_app.moc

# Compile
echo "Compiling..."
g++ -fPIC \
    -I$QT_PATH/include \
    -I$QT_PATH/include/QtCore \
    -I$QT_PATH/include/QtGui \
    -I$QT_PATH/include/QtWidgets \
    test_qt_app.cpp \
    -o test_qt_app \
    -L$QT_PATH/lib \
    -lQt6Core \
    -lQt6Gui \
    -lQt6Widgets \
    -Wl,-rpath,$QT_PATH/lib

if [ $? -eq 0 ]; then
    echo "Build successful! Binary: ./test_qt_app"
    echo "To run: LD_LIBRARY_PATH=$QT_PATH/lib:$LD_LIBRARY_PATH ./test_qt_app"
else
    echo "Build failed!"
    exit 1
fi
