# QtWebDriver Qt 6 Integration Findings

**Date**: November 3, 2025  
**Objective**: Embed QtWebDriver into a Qt 6.8.2 application (Wiki Option 1)  
**Result**: BLOCKED - Fundamental incompatibilities discovered

---

## Executive Summary

Attempting to embed QtWebDriver directly into a Qt 6 application (following the wiki's Option 1 approach) revealed **fundamental incompatibilities** between QtWebDriver's Chromium base library and Qt 6. The root cause is a conflict between:

1. **QtWebDriver's Chromium base**: Designed for Qt 4/5 with C++11
2. **Qt 6 requirements**: Requires C++17 with modern standard library

The integration fails during compilation due to **time.h include ordering conflicts** that cannot be resolved without modifying QtWebDriver's core codebase.

---

## Background: Integration Approaches

From the [QtWebDriver wiki](https://github.com/cisco-open-source/qtwebdriver/wiki/Use-QtWebDriver-to-run-your-application), two approaches exist:

### Option 1: Embedded (Attempted)
- **Description**: Modify application code to embed QtWebDriver server
- **Requirements**: 
  - Include `Headers.h` 
  - Call `wd_setup(argc, argv)` in main()
  - Link against QtWebDriver static libraries
- **Advantage**: Single process, direct control
- **Status**: ❌ **BLOCKED** (incompatible with Qt 6)

### Option 2: Registration (Not Attempted)
- **Description**: Register widget class with QtWebDriver, let WebDriver create the app
- **Requirements**: No app modification, register class in WebDriver build
- **Advantage**: No app code changes needed
- **Status**: ⏸️ Not tested

---

## Technical Issues Discovered

### 1. C++ Standard Version Conflict

**Issue**: Qt 6 requires C++17, QtWebDriver uses C++11

```cpp
// Qt 6.8.2 in qcompilerdetection.h:1260
#error "Qt requires a C++17 compiler"
```

**Impact**: When compiling with `-std=c++11`, Qt 6 headers fail immediately.

**Attempted Fix**: Changed to `-std=c++17`
- ✅ Qt 6 headers compile
- ❌ Exposes deeper compatibility issues with QtWebDriver base

---

### 2. time.h Include Ordering Conflict (CRITICAL)

**Root Cause**: Include dependency deadlock between Qt 6 and QtWebDriver

```
Qt 6 Headers
  ↓
QtCore/qelapsedtimer.h
  ↓
<chrono>  (C++17 standard library)
  ↓
<ctime>   (expects time functions in :: namespace)
  ↓
using ::clock;    ← ERROR: 'clock' has not been declared in '::'
using ::difftime; ← ERROR: 'difftime' has not been declared in '::'
using ::mktime;   ← ERROR: 'mktime' has not been declared in '::'
using ::time;     ← ERROR: 'time' has not been declared in '::'
...
```

**Why It Fails**:
1. Qt 6's `<chrono>` pulls in `<ctime>` automatically
2. `<ctime>` tries to import time functions into `std::` namespace
3. QtWebDriver's `base/time.h` hasn't been included yet to define them
4. If we include QtWebDriver first, Qt headers fail because they need to be included first

**This is a chicken-and-egg problem with no solution** using the current QtWebDriver codebase.

**Attempted Workarounds** (all failed):
- ❌ Include `<time.h>` before Qt headers → Still fails when `<ctime>` tries to import
- ❌ Include QtWebDriver headers first → Qt templates fail to compile
- ❌ Use `extern "C"` wrapper → Breaks C++ templates throughout Qt
- ❌ Define time functions manually → Type mismatches with chromium base
- ❌ `-fpermissive` flag → Still hard errors on undefined symbols

---

### 3. typeof Keyword (C++11 GCC Extension)

**Issue**: QtWebDriver uses `typeof` which isn't standard C++17

```cpp
// inc/base/eintr_wrapper.h:20
typeof(x) __eintr_result__;  // ← Not valid in C++17
```

**Fix Applied**: `-Dtypeof=__typeof__`
- ✅ Compiles in this file
- ❌ Doesn't solve the time.h issue

---

### 4. Template Deduction Failures

**Issue**: Qt 6 template argument deduction stricter than Qt 5

```cpp
// Qt 6 error in qarraydatapointer.h:487
error: no matching function for call to 'qMax(int, qsizetype)'
note: deduced conflicting types for parameter 'const T' ('int' and 'long long int')
```

**Cause**: Qt 6 uses `qsizetype` (64-bit) where Qt 5 used `int`  
**Impact**: Would require updating QtWebDriver's extension_qt code for Qt 6 types

---

### 5. QML/QtQuick Metatype System Changes

**Issue**: Qt 6 completely rewrote the metatype registration system

```cpp
error: 'QMetaTypeInterfaceWrapper<QJSValue>::metaType' is not a member of 'QMetaTypeInterfaceWrapper<QJSValue>'
error: 'QMetaTypeInterfaceWrapper<QQmlListReference>::metaType' is not a member...
```

**Cause**: QtWebDriver's Quick2 extension uses Qt 5 metatype API  
**Impact**: Would require rewriting Qt Quick integration for Qt 6

---

## What We Successfully Created

Despite the blocking issues, we made significant progress:

### 1. Qt 6 Compatible Test Application
**File**: `tests/test_qt_app.cpp`
- ✅ Qt 6 Widgets UI with interactive buttons
- ✅ Counter, text input, and display widgets
- ✅ Compiles and runs standalone (without QtWebDriver)
- ✅ Proper Qt 6 signal/slot connections

### 2. Minimal QtWebDriver Integration Header
**File**: `tests/wd_core_only.h`
- ✅ Stripped down version of `Headers.h`
- ✅ Only includes widgets support (no QML/Quick)
- ✅ Uses correct API calls (`Server::GetInstance()`, `Configure(cmd_line)`)
- ✅ Fixed class names (`WidgetViewEnumeratorImpl` not `QWidget...`)
- ❌ Still can't compile due to time.h conflicts

### 3. Build System Understanding
**File**: `tests/build_test_app.sh`
- ✅ Identified required static libraries:
  - `libWebDriver_core.a` (3MB)
  - `libWebDriver_extension_qt_base.a` (730KB)
  - `libchromium_base.a` (1.8MB)
  - `libtest_widgets.a` (536KB)
- ✅ Correct include paths for QtWebDriver
- ✅ Proper defines: `-DOS_POSIX`, `-DOS_LINUX`, `-DQT_NO_QML`
- ❌ Can't link due to compilation failures

---

## Compilation Error Summary

**Final error count**: 10 hard errors (all time.h related)

```
/usr/include/c++/11/ctime:64:11: error: 'clock' has not been declared in '::'
/usr/include/c++/11/ctime:65:11: error: 'difftime' has not been declared in '::'
/usr/include/c++/11/ctime:66:11: error: 'mktime' has not been declared in '::'
/usr/include/c++/11/ctime:67:11: error: 'time' has not been declared in '::'
/usr/include/c++/11/ctime:68:11: error: 'asctime' has not been declared in '::'
/usr/include/c++/11/ctime:69:11: error: 'ctime' has not been declared in '::'
/usr/include/c++/11/ctime:70:11: error: 'gmtime' has not been declared in '::'
/usr/include/c++/11/ctime:71:11: error: 'localtime' has not been declared in '::'
/usr/include/c++/11/ctime:72:11: error: 'strftime' has not been declared in '::'
/usr/include/c++/11/ctime:80:11: error: 'timespec_get' has not been declared in '::'
```

**These errors are insurmountable** without modifying QtWebDriver's `inc/base/time.h` and related Chromium base code.

---

## Why This Matters

### QtWebDriver's Chromium Base Assumptions
QtWebDriver was designed when:
- Qt 4/5 didn't automatically include `<chrono>` in core headers
- C++11 didn't have as strict template requirements
- The Chromium base library worked alongside Qt headers without conflicts

### Qt 6's Breaking Changes
Qt 6 introduced:
- Mandatory C++17 (with stricter template deduction)
- Automatic `<chrono>` inclusion in timing headers
- New metatype system for QML/Quick
- 64-bit `qsizetype` throughout the API

**These changes are fundamentally incompatible** with QtWebDriver's current implementation.

---

## Required Changes for Qt 6 Support

To make the embedded approach (Option 1) work with Qt 6, QtWebDriver would need:

### Core Changes (High Priority)
1. **Fix base/time.h**:
   - Ensure time functions are declared before `<ctime>` tries to import them
   - Possibly move to C++ `<chrono>` instead of C time functions
   - Add proper namespacing to avoid conflicts

2. **Upgrade to C++17**:
   - Replace `typeof` with `decltype` or `auto`
   - Update all build scripts from `-std=c++11` to `-std=c++17`
   - Fix template deduction issues

3. **Update extension_qt for Qt 6**:
   - Port metatype registration to Qt 6 API
   - Handle `qsizetype` vs `int` type conflicts
   - Update QML/Quick2 extensions for Qt 6 modules

### Optional Improvements
4. **Separate base library**:
   - Consider removing Chromium base dependency
   - Use Qt's own base classes where possible
   - Would simplify Qt 6 integration significantly

---

## Recommended Path Forward

### Option A: Fix QtWebDriver Core (High Effort)
**Effort**: 2-4 weeks  
**Scope**: Modify QtWebDriver's Chromium base for Qt 6

**Steps**:
1. Create Qt 6 compatibility branch
2. Fix `inc/base/time.h` include ordering
3. Port to C++17 standard
4. Update extension_qt for Qt 6 API
5. Test across platforms
6. Submit PR to upstream

**Risk**: May require extensive testing and validation

### Option B: Try Registration Approach (Low Effort)
**Effort**: 1-2 days  
**Scope**: Try Wiki Option 2 (register widget class)

**Steps**:
1. Don't modify test application
2. Register `TestWindow` class in QtWebDriver build
3. Let WebDriver launch the application
4. Test if this avoids the time.h conflicts

**Risk**: May have same Qt 6 issues if WebDriver still uses Chromium base

### Option C: Run WebDriver Separately (Immediate)
**Effort**: Already working  
**Scope**: Use existing separate process approach

**Current Status**: ✅ **Already functional**
- Run WebDriver server in separate process
- Run Qt app in another process
- Connect via HTTP/WebSocket
- No code changes to app needed

**Limitation**: Requires two processes, but avoids all Qt 6 conflicts

---

## Files Created/Modified

### New Files
- `tests/test_qt_app.cpp` - Qt 6 test application with UI
- `tests/build_test_app.sh` - Build script with QtWebDriver linking
- `tests/run_test_app.sh` - Run script for embedded mode
- `tests/wd_core_only.h` - Minimal Qt 6 integration header
- `tests/Headers_Qt6_Minimal.h` - Earlier attempt (obsolete)
- `tests/QT6_INTEGRATION_FINDINGS.md` - This document

### Modified Files
None (standalone app compiles without modifications)

---

## Conclusion

**The embedded QtWebDriver approach (Wiki Option 1) is currently incompatible with Qt 6** due to fundamental conflicts between:
- QtWebDriver's C++11 Chromium base library
- Qt 6's C++17 requirements and automatic chrono includes

The **time.h include ordering deadlock cannot be resolved** without modifying QtWebDriver's core `inc/base/time.h` implementation.

**Recommended immediate action**: Use Option C (separate processes) which already works, or try Option B (registration approach) to see if it avoids the embedding conflicts.

**Long-term solution**: QtWebDriver needs a Qt 6 compatibility update at the core level, including:
- C++17 port
- time.h conflict resolution  
- Qt 6 metatype API updates
- Template deduction fixes

---

## Environment Details

```
Qt Version:         6.8.2
Qt Path:           /opt/qt/6.8.2/gcc_64
Compiler:          g++ 11 (Ubuntu 22.04)
C++ Standard:      C++17 (required by Qt 6)
QtWebDriver:       WD_1.X_dev branch
Build System:      gyp → static libraries
Test Platform:     Dev container (Ubuntu 22.04.5 LTS)
```

## Contact

For questions about these findings:
- See conversation history in this session
- Reference this document when discussing Qt 6 integration
- Consider upstream QtWebDriver issue/PR for Qt 6 support
