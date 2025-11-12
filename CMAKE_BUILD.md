# CMake Build System for QtWebDriver

## Overview

QtWebDriver now uses CMake as its build system, replacing the previous GYP-based system. This provides better cross-platform support, improved IDE integration, and easier dependency management.

## VSCode CMake Extension Setup

If you're using the CMake Tools extension in VSCode:

1. **Copy the example settings file**:
   ```bash
   cp .vscode/settings.json.example .vscode/settings.json
   ```

2. **Edit `.vscode/settings.json`** and update the Qt path:
   ```json
   {
       "cmake.configureSettings": {
           "CMAKE_PREFIX_PATH": "/opt/qt/6.8.2/gcc_64",
           "QT_VERSION": "6"
       }
   }
   ```

3. **Configure in VSCode**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
   - Type "CMake: Configure"
   - Select your kit (e.g., GCC, Clang, MSVC)

4. **Build in VSCode**:
   - Press `F7` or use "CMake: Build"

### Common VSCode Qt Paths

**Linux**:
```json
"CMAKE_PREFIX_PATH": "/opt/qt/6.8.2/gcc_64"
// or
"CMAKE_PREFIX_PATH": "$HOME/Qt/6.8.2/gcc_64"
```

**macOS**:
```json
"CMAKE_PREFIX_PATH": "/usr/local/opt/qt@6"
// or
"CMAKE_PREFIX_PATH": "$HOME/Qt/6.8.2/macos"
```

**Windows**:
```json
"CMAKE_PREFIX_PATH": "C:/Qt/6.8.2/msvc2019_64"
```

## Quick Start

### Basic Build

```bash
# Using the build script (recommended)
./build_cmake.sh

# Or manually
mkdir build
cd build
cmake ..
cmake --build .
```

### Build with Custom Qt Version

```bash
# For Qt 5
./build_cmake.sh out/qt5 Release 5

# For Qt 6 (default)
./build_cmake.sh out/qt6 Release 6
```

### Build with Custom Configuration

```bash
mkdir build
cd build

# Configure with options
cmake .. \
    -DQT_VERSION=6 \
    -DCMAKE_BUILD_TYPE=Release \
    -DWD_CONFIG_WEBKIT=ON \
    -DWD_CONFIG_QUICK=ON \
    -DBUILD_TESTS=ON

# Build
cmake --build . --parallel $(nproc)

# Install
cmake --install . --prefix /usr/local
```

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `QT_VERSION` | 6 | Qt version to use (5 or 6) |
| `CMAKE_BUILD_TYPE` | Release | Build type (Debug, Release, RelWithDebInfo) |
| `WD_CONFIG_QWIDGET_BASE` | ON | Enable QWidget support |
| `WD_CONFIG_WEBKIT` | OFF | Enable WebKit support |
| `WD_CONFIG_QUICK` | ON | Enable Qt Quick support |
| `WD_CONFIG_PLAYER` | OFF | Enable player support |
| `WD_CONFIG_ONE_KEYRELEASE` | OFF | Enable one key release |
| `WD_BUILD_MONGOOSE` | ON | Build with mongoose |
| `BUILD_SHARED_LIBS` | OFF | Build shared libraries instead of static |
| `BUILD_TESTS` | ON | Build test executables |

## Specifying Qt Location

If Qt is not in a standard location, you can specify it using `CMAKE_PREFIX_PATH`:

```bash
cmake .. -DCMAKE_PREFIX_PATH=/opt/qt/6.8.2/gcc_64
```

Or set it as an environment variable:

```bash
export CMAKE_PREFIX_PATH=/opt/qt/6.8.2/gcc_64
cmake ..
```

## Using Configuration File

You can create a configuration file for repeated builds:

```bash
# Copy the template
cp cmake_config.cmake.template cmake_config.cmake

# Edit cmake_config.cmake with your settings
vim cmake_config.cmake

# Use it in build
mkdir build
cd build
cmake .. -C ../cmake_config.cmake
cmake --build .
```

## Build Targets

The build system creates the following targets:

### Libraries (Static)
- `chromium_base` - Chromium base library
- `WebDriver_core` - WebDriver core library
- `WebDriver_extension_qt_base` - Qt base extension
- `WebDriver_extension_qt_web` - Qt WebKit extension (if WD_CONFIG_WEBKIT=ON)
- `WebDriver_extension_qt_quick` - Qt Quick extension (if WD_CONFIG_QUICK=ON)

### Libraries (Shared, Linux only)
- `chromium_base_shared`
- `WebDriver_core_shared`
- `WebDriver_extension_qt_base_shared`
- `WebDriver_extension_qt_web_shared` (if WD_CONFIG_WEBKIT=ON)
- `WebDriver_extension_qt_quick_shared` (if WD_CONFIG_QUICK=ON)

### Test Executables
- `WebDriver` - Full WebDriver test executable (if WD_CONFIG_WEBKIT=ON)
- `WebDriver_noWebkit` - WebDriver without WebKit
- `WebDriver_noWebkit_sharedLibs` - WebDriver with shared libraries (Linux only)

## Platform-Specific Notes

### Linux
```bash
./build_cmake.sh
```

### Windows
```powershell
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022"
cmake --build . --config Release
```

### macOS
```bash
mkdir build
cd build
cmake .. -G Xcode
cmake --build . --config Release
```

## Comparison with GYP Build

| Feature | GYP (Old) | CMake (New) |
|---------|-----------|-------------|
| Configuration | wd.gypi files | CMakeLists.txt |
| Build command | `build.sh` | `build_cmake.sh` or `cmake --build` |
| IDE support | Limited | Excellent (VSCode, CLion, etc.) |
| Qt integration | Manual | Automatic via find_package |
| Parallel builds | Yes | Yes (default) |
| Cross-platform | Limited | Excellent |

## Migration from GYP

The old GYP build files are still present but are no longer used. To migrate:

1. Use `build_cmake.sh` instead of `build.sh`
2. Configuration is now done via CMake options instead of `.gypi` files
3. Output structure is similar but organized by CMake conventions

## Troubleshooting

### Qt not found

If CMake cannot find Qt, you'll see an error like:
```
CMake Error at CMakeLists.txt:52 (find_package):
  By not providing "FindQt6.cmake" in CMAKE_MODULE_PATH...
```

**Solutions**:

1. **Set CMAKE_PREFIX_PATH**:
   ```bash
   cmake -DCMAKE_PREFIX_PATH=/opt/qt/6.8.2/gcc_64 ..
   ```

2. **For VSCode CMake Extension**, create/edit `.vscode/settings.json`:
   ```json
   {
       "cmake.configureSettings": {
           "CMAKE_PREFIX_PATH": "/opt/qt/6.8.2/gcc_64"
       }
   }
   ```
   Then reload VSCode or run "CMake: Delete Cache and Reconfigure"

3. **Set environment variable**:
   ```bash
   export CMAKE_PREFIX_PATH=/opt/qt/6.8.2/gcc_64
   cmake ..
   ```

4. **Use cmake_config.cmake**:
   ```bash
   cp cmake_config.cmake.template cmake_config.cmake
   # Edit cmake_config.cmake to set your Qt path
   cmake -C cmake_config.cmake ..
   ```

### MOC errors
```bash
# Clean and rebuild
rm -rf build
mkdir build && cd build
cmake ..
cmake --build .
```

### Linking errors with shared libraries
```bash
# Make sure you're building on Linux
# Set LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
```

## Advanced Usage

### Debug Build
```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug
```

### Verbose Build
```bash
cmake --build . --verbose
```

### Clean Build
```bash
cmake --build . --target clean
# or
rm -rf build/*
```

### Install to Custom Location
```bash
cmake --install . --prefix /custom/install/path
```

## Getting Help

For more information:
- Main README: [Readme.md](Readme.md)
- CMake Documentation: https://cmake.org/documentation/
- Qt CMake Manual: https://doc.qt.io/qt-6/cmake-manual.html

