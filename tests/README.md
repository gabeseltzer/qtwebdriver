# QtWebDriver Tests

This folder contains test applications and scripts for QtWebDriver.

## Test Scripts

### Python Tests (Selenium 4)

#### `test_selenium.py`
Basic Selenium 4 connectivity test. Demonstrates:
- Creating a WebDriver session with W3C capabilities
- Getting window handles
- Getting current window handle
- Getting window title
- Basic session management

**Run:**
```bash
cd /workspaces/qtwebdriver
source .venv/bin/activate
python tests/test_selenium.py
```

#### `test_w3c_endpoints.py`
Comprehensive W3C WebDriver protocol endpoint test. Tests:
- Session creation (W3C format)
- Window handles
- Current window handle
- Script execution (sync)
- Timeout configuration (W3C format)
- Async script execution
- Window title
- Window maximize

**Run:**
```bash
cd /workspaces/qtwebdriver
source .venv/bin/activate
python tests/test_w3c_endpoints.py
```

#### `test_webdriver.py`
Original WebDriver test using direct HTTP requests (JSONWire protocol).

**Run:**
```bash
cd /workspaces/qtwebdriver
source .venv/bin/activate
python tests/test_webdriver.py
```

#### `test_qt_widgets.py`
Test script for interacting with Qt Widgets application. Demonstrates:
- Finding Qt widgets by name
- Clicking buttons
- Reading labels
- Entering text
- Counter operations

**Run:**
```bash
# First start the Qt app and WebDriver (see Qt Application section)
cd /workspaces/qtwebdriver
source .venv/bin/activate
python tests/test_qt_widgets.py
```

#### `test_ui_buttons.py`
Test script for web-based UI (requires QtWebEngine). Tests:
- Button clicks
- Text input
- Counter operations
- DOM element verification

**Note:** Requires a Qt application with WebEngine/WebKit support.

## Qt Application

### `test_qt_app.cpp`
Standalone Qt 6.8.2 Widgets application with interactive UI:
- **Simple Buttons**: Say Hello, Say Goodbye, Clear Message
- **Counter**: Increment, Decrement, Reset with display
- **Text Input**: Line edit with submit button
- **Result Display**: Shows action results

All widgets are named with `objectName` for WebDriver automation.

### Building the Qt App

```bash
cd /workspaces/qtwebdriver/tests
./build_test_app.sh
```

This creates the `test_qt_app` binary.

### Running with QtWebDriver

Option 1 - Manual:
```bash
# Terminal 1: Start Qt app
cd /workspaces/qtwebdriver/tests
LD_LIBRARY_PATH=/opt/qt/6.8.2/gcc_64/lib:$LD_LIBRARY_PATH \
QT_QPA_PLATFORM=offscreen \
./test_qt_app &

# Terminal 2: Start WebDriver
cd /workspaces/qtwebdriver
LD_LIBRARY_PATH=/opt/qt/6.8.2/gcc_64/lib:$LD_LIBRARY_PATH \
./out/desktop/release/Default/WebDriver_noWebkit --port=9517
```

Option 2 - Using script:
```bash
cd /workspaces/qtwebdriver/tests
./run_test_app.sh
```

## Prerequisites

### Python Environment
```bash
cd /workspaces/qtwebdriver
python3 -m venv .venv
source .venv/bin/activate
pip install selenium
```

### WebDriver Server
QtWebDriver must be built and running on port 9517 (default).

### Qt 6.8.2
Required for building and running the Qt test application.
Location: `/opt/qt/6.8.2/gcc_64`

## Test Results

All W3C protocol tests pass successfully:
- ✅ Session creation (W3C capabilities)
- ✅ Window/tab management
- ✅ Script execution
- ✅ Timeout configuration
- ✅ All routes correctly registered

## Notes

- Qt Widgets tests require the Qt application to be running before starting tests
- Web-based tests require QtWebEngine/QtWebKit support
- All tests support both W3C and JSONWire protocols for backward compatibility
