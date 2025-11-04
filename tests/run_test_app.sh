#!/bin/bash

# Start Qt Test Application with Embedded QtWebDriver

QT_PATH=/opt/qt/6.8.2/gcc_64
WD_ROOT=/workspaces/qtwebdriver

echo "Starting Qt Test Application with Embedded QtWebDriver"
echo "========================================================"

# Check if binary exists
if [ ! -f "./test_qt_app" ]; then
    echo "Error: test_qt_app not found. Run ./build_test_app.sh first"
    exit 1
fi

# Set library paths
export LD_LIBRARY_PATH=$QT_PATH/lib:$WD_ROOT/out/desktop/release/Default:$LD_LIBRARY_PATH

# Uncomment the next line to run in headless mode (no GUI window)
# export QT_QPA_PLATFORM=offscreen

echo ""
echo "Starting application with embedded QtWebDriver..."
echo "WebDriver will listen on port 9517 (configurable with --port=XXXX)"
echo "Press Ctrl+C to stop"
echo ""

# Run the application with embedded WebDriver
# You can pass QtWebDriver arguments like --port=9517, --verbose, etc.
./test_qt_app --port=9517 --verbose
