# VSCode CMake Configuration

This directory contains VSCode-specific settings for building QtWebDriver with CMake.

## Setup

1. **Copy the example settings**:
   ```bash
   cp settings.json.example settings.json
   ```

2. **Edit `settings.json`** to match your Qt installation path:
   ```json
   {
       "cmake.configureSettings": {
           "CMAKE_PREFIX_PATH": "/opt/qt/6.8.2/gcc_64",
           "QT_VERSION": "6"
       }
   }
   ```

3. **Reload VSCode** or run:
   - `Ctrl+Shift+P` → "CMake: Delete Cache and Reconfigure"

## Common Qt Paths

### Linux
- `/opt/qt/6.8.2/gcc_64`
- `$HOME/Qt/6.8.2/gcc_64`
- `/usr/local/Qt-6.8.2`

### macOS
- `/usr/local/opt/qt@6`
- `$HOME/Qt/6.8.2/macos`
- `/Applications/Qt/6.8.2/clang_64`

### Windows
- `C:/Qt/6.8.2/msvc2019_64`
- `C:/Qt/6.8.2/mingw_64`

## Additional Settings

You can add more CMake settings as needed:

```json
{
    "cmake.configureSettings": {
        "CMAKE_PREFIX_PATH": "/opt/qt/6.8.2/gcc_64",
        "QT_VERSION": "6",
        "CMAKE_BUILD_TYPE": "Debug",
        "WD_CONFIG_WEBKIT": "OFF",
        "WD_CONFIG_QUICK": "ON"
    },
    "cmake.buildDirectory": "${workspaceFolder}/build",
    "cmake.generator": "Unix Makefiles",
    "cmake.parallelJobs": 4
}
```

## Note

The `settings.json` file is ignored by git (in .gitignore) so you can customize it for your local environment without affecting other developers.
