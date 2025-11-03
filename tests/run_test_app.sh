#!/bin/bash

# Start Qt Test Application and QtWebDriver

QT_PATH=/opt/qt/6.8.2/gcc_64
WD_BINARY=../out/desktop/release/Default/WebDriver_noWebkit

echo "Starting Qt Test Application with QtWebDriver"
echo "=============================================="

# Check if binaries exist
if [ ! -f "./test_qt_app" ]; then
    echo "Error: test_qt_app not found. Run ./build_test_app.sh first"
    exit 1
fi

if [ ! -f "$WD_BINARY" ]; then
    echo "Error: WebDriver binary not found at $WD_BINARY"
    exit 1
fi

# Set Qt library path
export LD_LIBRARY_PATH=$QT_PATH/lib:$LD_LIBRARY_PATH

# Uncomment the next line to run in headless mode (no GUI window)
# export QT_QPA_PLATFORM=offscreen

echo ""
echo "Starting Qt application in background (with GUI)..."
./test_qt_app &
QT_APP_PID=$!
echo "Qt app started with PID: $QT_APP_PID"

# Give Qt app time to start
sleep 2

echo ""
echo "Starting QtWebDriver..."
echo "Port: 9517"
echo "Press Ctrl+C to stop both processes"
echo ""

# Start WebDriver (this will run in foreground)
$WD_BINARY --port=9517 --session-log-level=INFO

# Cleanup when WebDriver exits
echo ""
echo "Stopping Qt application (PID: $QT_APP_PID)..."
kill $QT_APP_PID 2>/dev/null
echo "Done."
