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

### Option 1: Embedded QtWebDriver (Following Wiki Approach)

Embed QtWebDriver directly into your Qt 6 application following the [QtWebDriver wiki](https://github.com/cisco-open-source/qtwebdriver/wiki/Use-QtWebDriver-to-run-your-application):

**Prerequisites:**
1. Build QtWebDriver with Qt 6 support:
   ```bash
   cp qt6_sample_config.gypi wd_config.gypi
   # Edit wd_config.gypi with your Qt 6 paths
   ./build.sh
   ```

2. Include QtWebDriver headers in your application:
   ```cpp
   // Include ALL Qt headers FIRST
   #include <QApplication>
   #include <QMainWindow>
   // ... other Qt headers
   
   // THEN include QtWebDriver headers
   #include "wd_core_only.h"
   ```

3. Initialize QtWebDriver in main():
   ```cpp
   int main(int argc, char *argv[]) {
       base::AtExitManager exit;
       
       QApplication app(argc, argv);
       app.setQuitOnLastWindowClosed(false);
       
       // Initialize QtWebDriver
       wd_helpers::setup(argc, argv);
       
       // Your application code
       return app.exec();
   }
   ```

4. Build and link:
   ```bash
   cd tests
   ./build_qt6_app_embedded.sh
   ```

5. Run:
   ```bash
   ./qt6_test_app_embedded --port=9517
   ```

**Note:** With C++17 enabled in the build system, the header conflicts mentioned in earlier findings are mitigated. However, if you encounter build issues, see `tests/QT6_INTEGRATION_FINDINGS.md` for details.

### Option 2: Separate Process (Alternative)

Run QtWebDriver as a separate process and connect to your Qt 6 application:

1. Start QtWebDriver server:
   ```bash
   ./WebDriver --port=9517
   ```

2. Run your Qt 6 application in a separate process

3. Connect via Selenium/WebDriver client

This approach avoids potential header conflicts and is simpler for applications that don't need tight integration.

### Option 3: Registration Approach

Register your Qt 6 widget class with QtWebDriver and let WebDriver create the application instance.
See the QtWebDriver wiki for details on this approach.

## Known Limitations

### QtWebKit Support

QtWebKit is not available in Qt 6. Set `WD_CONFIG_WEBKIT: '0'` in your configuration.

### Embedding Considerations

The Qt 6 test application (`qt6_test_app.cpp`) demonstrates the embedded approach following the wiki instructions. With C++17 enabled (`-std=gnu++17` in `wd_build_options.gypi`), many of the header conflicts are resolved.

**Build requirements for embedding:**
- QtWebDriver must be built first with Qt 6 support
- Use the provided `build_qt6_app_embedded.sh` script
- Link against: `libWebDriver_core.a`, `libWebDriver_extension_qt_base.a`, `libchromium_base.a`

If you encounter compilation issues, you may need to:
- Ensure Qt headers are included before QtWebDriver headers
- Use the workarounds documented in `tests/QT6_INTEGRATION_FINDINGS.md`
- Or fall back to the separate process approach (Option 2)

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
