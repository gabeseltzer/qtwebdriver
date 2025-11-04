# Qt 6 Support in QtWebDriver

## Overview

QtWebDriver now supports Qt 6 in addition to Qt 4 and Qt 5. This document describes how to build and use QtWebDriver with Qt 6.

## Configuration

### Sample Configuration File

A sample configuration file for Qt 6 is provided: `qt6_sample_config.gypi`

To use it, copy it to your build configuration:
```bash
cp qt6_sample_config.gypi wd_config.gypi
```

Then edit `wd_config.gypi` to match your Qt 6 installation paths:
- `QT_INC_PATH`: Path to Qt 6 include files
- `QT_BIN_PATH`: Path to Qt 6 binaries
- `QT_LIBEXEC_PATH`: Path to Qt 6 libexec (where moc, uic, rcc are located)
- `QT_LIB_PATH`: Path to Qt 6 libraries

### Key Configuration Variables

- `QT5`: Set to `'0'` for Qt 6
- `QT6`: Set to `'1'` for Qt 6
- `WD_CONFIG_WEBKIT`: Should be `'0'` for Qt 6 (QtWebKit is not available in Qt 6)
- `WD_CONFIG_QUICK`: Can be `'1'` to enable Qt Quick/QML support
- `WD_CONFIG_QWIDGET_BASE`: Can be `'1'` to enable Qt Widgets support

## Building with Qt 6

1. Install Qt 6 on your system
2. Copy and configure the Qt 6 configuration file:
   ```bash
   cp qt6_sample_config.gypi wd_config.gypi
   # Edit wd_config.gypi with your Qt 6 paths
   ```
3. Build QtWebDriver:
   ```bash
   ./build.sh
   ```

## Qt 6 Test Application

A test application is provided in `tests/qt6_test_app.cpp` to verify Qt 6 functionality.

### Building the Test Application

Using CMake (recommended for Qt 6):
```bash
cd tests
mkdir build
cd build
cmake ..
make
./qt6_test_app
```

### Test Application Features

The test application includes:
- Interactive buttons (Hello, Goodbye, Clear)
- Counter with increment/decrement/reset
- Text input and submission
- Result display area

All widgets have object names set for easy WebDriver automation:
- `btn-hello`, `btn-goodbye`, `btn-clear`
- `btn-increment`, `btn-decrement`, `btn-reset`
- `btn-submit`
- `counter` (label)
- `text-input` (line edit)
- `result-text` (result label)

## Usage with Qt 6 Applications

### Option 1: Separate Process (Recommended)

Run QtWebDriver as a separate process and connect to your Qt 6 application:

1. Start QtWebDriver server:
   ```bash
   ./WebDriver --port=9517
   ```

2. Run your Qt 6 application in a separate process

3. Connect via Selenium/WebDriver client

This approach avoids potential header conflicts and is the most reliable method.

### Option 2: Registration Approach

Register your Qt 6 widget class with QtWebDriver and let WebDriver create the application instance.
See the QtWebDriver wiki for details on this approach.

## Known Limitations

### QtWebKit Support

QtWebKit is not available in Qt 6. Set `WD_CONFIG_WEBKIT: '0'` in your configuration.

### Embedding QtWebDriver (Not Recommended)

Directly embedding QtWebDriver into Qt 6 applications may encounter header conflicts between:
- QtWebDriver's Chromium base library (C++11/C++17)
- Qt 6's automatic inclusion of `<chrono>` headers

For this reason, we recommend using the separate process approach (Option 1) or the registration approach (Option 2).

## Compatibility Notes

- **C++ Standard**: Qt 6 requires C++17. QtWebDriver's build system has been updated to use `-std=gnu++17`.
- **Qt Modules**: Qt 6 has reorganized modules. Ensure you link against the correct Qt 6 modules.
- **Metatype System**: Qt 6 has a new metatype registration system. The source code includes Qt 6-specific version checks to handle this.

## Migration from Qt 5

If migrating from Qt 5:

1. Update your configuration file from `qt5_sample_config.gypi` to `qt6_sample_config.gypi`
2. Set `QT5: '0'` and `QT6: '1'`
3. Set `WD_CONFIG_WEBKIT: '0'` (QtWebKit not available in Qt 6)
4. Update Qt paths to point to Qt 6 installation
5. Add `QT_LIBEXEC_PATH` to point to Qt 6 libexec directory
6. Rebuild QtWebDriver

## Source Code Compatibility

The QtWebDriver source code includes runtime version checks for Qt 6 compatibility:
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
    // Qt 6 specific code
#else
    // Qt 4/5 code
#endif
```

Files with Qt 6 compatibility updates:
- `src/vnc/vncclient.cc`
- `src/webdriver/extension_qt/widget_view_executor.cc`
- `src/webdriver/extension_qt/quick2_view_executor.cc`
- `src/webdriver/extension_qt/q_view_executor.cc`
- `src/third_party/mimetypes-qt4/mimetypes/qmimetype.h`

## Troubleshooting

### Build Errors

If you encounter build errors:
1. Verify Qt 6 is properly installed: `qmake6 --version` or `qmake -version`
2. Check that all paths in `wd_config.gypi` are correct
3. Ensure `QT6: '1'` is set in your configuration
4. Verify `QT_LIBEXEC_PATH` points to the directory containing moc, uic, rcc

### Runtime Issues

If QtWebDriver cannot connect to your Qt 6 application:
1. Ensure the application has object names set on widgets
2. Verify the application name is set correctly
3. Check that QtWebDriver server is running on the expected port

## References

- [QtWebDriver Wiki](https://github.com/cisco-open-source/qtwebdriver/wiki)
- [Qt 6 Documentation](https://doc.qt.io/qt-6/)
- [Qt 6 Migration Guide](https://doc.qt.io/qt-6/portingguide.html)
