# Synopsis
QtWebDriver is a WebDriver implementation for Qt.

It can be used to perform automated Selenium testing of applications based on:
* QtWebkit
* QWidgets
* QQuick1 (Qt4) or QQuick2 (Qt5)  

If you hadn't used Selenium for automated testing, you may also find this links helpful:
* https://github.com/seleniumhq/selenium
* http://docs.seleniumhq.org/  

# Build and run

QtWebDriver now uses **CMake** as its build system (migrated from GYP in November 2025).

## Quick Start

```bash
# Basic build with Qt6
./build.sh

# Or specify parameters: [output_dir] [platform] [build_type] [qt_path]
./build.sh out desktop release /opt/qt/6.8.2/gcc_64

# For Qt5
./build.sh out desktop release /opt/Qt5/5.15.2/gcc_64
```

## Platform-Specific Builds

- **Linux/Desktop**: `./build.sh`
- **macOS**: `./build_mac.sh`
- **iOS**: `./build_ios.sh`
- **Android**: `./build_android.sh`

## Documentation

- **CMake Build Guide**: See [CMAKE_BUILD.md](CMAKE_BUILD.md) for complete CMake build documentation
- **Release Notes**: Pre-built binaries are in the Releases section: https://github.com/cisco-open-source/qtwebdriver/releases

# Other links
* An example how to customize QtWebDriver in `src/Test/main.cc`   
* [Doxygen](http://cisco-open-source.github.io/qtwebdriver/html)  
* [Wiki](https://github.com/cisco-open-source/qtwebdriver/wiki)  
* Mailing list: qtwebdriver-users@external.cisco.com

# License
LGPLv2.1
