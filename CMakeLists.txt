cmake_minimum_required(VERSION 3.16)

project(QtWebDriver VERSION 1.0.0 LANGUAGES CXX C)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

# Options for build configuration
option(WD_CONFIG_QWIDGET_BASE "Enable QWidget support" ON)
option(WD_CONFIG_WEBKIT "Enable WebKit support" OFF)
option(WD_CONFIG_QUICK "Enable Qt Quick support" ON)
option(WD_CONFIG_PLAYER "Enable player support" OFF)
option(WD_CONFIG_ONE_KEYRELEASE "Enable one key release" OFF)
option(WD_BUILD_MONGOOSE "Build with mongoose" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(BUILD_TESTS "Build test executables" ON)

# Platform detection
if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(LINUX TRUE)
endif()

# Qt version selection (default to Qt6)
set(QT_VERSION "6" CACHE STRING "Qt version to use (5 or 6)")
set_property(CACHE QT_VERSION PROPERTY STRINGS "5" "6")

if(QT_VERSION EQUAL 6)
    set(QT6 TRUE)
    set(QT5 FALSE)
elseif(QT_VERSION EQUAL 5)
    set(QT5 TRUE)
    set(QT6 FALSE)
else()
    message(FATAL_ERROR "Unsupported Qt version: ${QT_VERSION}. Use 5 or 6.")
endif()

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo")

# Output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Help find Qt - check common installation locations if not specified
if(NOT DEFINED CMAKE_PREFIX_PATH OR CMAKE_PREFIX_PATH STREQUAL "")
    # Common Qt installation paths
    set(QT_SEARCH_PATHS
        "$ENV{HOME}/Qt/${QT_VERSION}.*/gcc_64"
        "$ENV{HOME}/Qt${QT_VERSION}/*"
        "/opt/qt/${QT_VERSION}.*/gcc_64"
        "/opt/Qt/${QT_VERSION}.*/gcc_64"
        "/opt/Qt${QT_VERSION}/*"
        "/usr/local/Qt-${QT_VERSION}.*"
        "/usr/local/opt/qt@${QT_VERSION}"
        "/usr/local/opt/qt${QT_VERSION}"
        "C:/Qt/Qt${QT_VERSION}.*/*/msvc*"
        "C:/Qt/${QT_VERSION}.*/msvc*"
    )
    
    foreach(search_path ${QT_SEARCH_PATHS})
        file(GLOB qt_paths ${search_path})
        if(qt_paths)
            list(GET qt_paths 0 qt_path)
            if(EXISTS "${qt_path}")
                message(STATUS "Found Qt at: ${qt_path}")
                set(CMAKE_PREFIX_PATH ${qt_path})
                break()
            endif()
        endif()
    endforeach()
endif()

# Find Qt
if(QT6)
    find_package(Qt6 COMPONENTS Core Gui Widgets Network Xml)
    if(NOT Qt6_FOUND)
        message(FATAL_ERROR 
            "\n"
            "Qt6 not found!\n"
            "\n"
            "Please specify Qt installation path using one of these methods:\n"
            "  1. Set CMAKE_PREFIX_PATH:\n"
            "     cmake -DCMAKE_PREFIX_PATH=/path/to/qt/6.x.x/gcc_64 ..\n"
            "  2. Set Qt6_DIR:\n"
            "     cmake -DQt6_DIR=/path/to/qt/6.x.x/gcc_64/lib/cmake/Qt6 ..\n"
            "  3. Set environment variable:\n"
            "     export CMAKE_PREFIX_PATH=/path/to/qt/6.x.x/gcc_64\n"
            "\n"
            "Common Qt6 paths:\n"
            "  - Linux: /opt/qt/6.8.2/gcc_64 or ~/Qt/6.8.2/gcc_64\n"
            "  - macOS: /usr/local/opt/qt@6 or ~/Qt/6.8.2/macos\n"
            "  - Windows: C:/Qt/6.8.2/msvc2019_64\n"
            "\n"
            "For VSCode CMake extension, create .vscode/settings.json:\n"
            "{\n"
            "  \"cmake.configureSettings\": {\n"
            "    \"CMAKE_PREFIX_PATH\": \"/path/to/qt/6.8.2/gcc_64\"\n"
            "  }\n"
            "}\n"
        )
    endif()
    
    if(WD_CONFIG_QUICK)
        find_package(Qt6 REQUIRED COMPONENTS Quick Qml)
    endif()
    if(WD_CONFIG_WEBKIT)
        find_package(Qt6 COMPONENTS WebEngineWidgets)
    endif()
    
    # Get Qt paths for tools
    get_target_property(QT_QMAKE_EXECUTABLE Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(QT_BIN_DIR "${QT_QMAKE_EXECUTABLE}" DIRECTORY)
    get_filename_component(QT_INSTALL_PREFIX "${QT_BIN_DIR}/.." ABSOLUTE)
    set(QT_MOC_EXECUTABLE "${QT_BIN_DIR}/moc")
    set(QT_UIC_EXECUTABLE "${QT_BIN_DIR}/uic")
    set(QT_RCC_EXECUTABLE "${QT_BIN_DIR}/rcc")
    
    # Handle libexec vs bin directory for moc/uic/rcc
    if(EXISTS "${QT_INSTALL_PREFIX}/libexec/moc")
        set(QT_MOC_EXECUTABLE "${QT_INSTALL_PREFIX}/libexec/moc")
        set(QT_UIC_EXECUTABLE "${QT_INSTALL_PREFIX}/libexec/uic")
        set(QT_RCC_EXECUTABLE "${QT_INSTALL_PREFIX}/libexec/rcc")
    endif()
    
    set(QT_LIBRARIES Qt6::Core Qt6::Gui Qt6::Widgets Qt6::Network Qt6::Xml)
    if(WD_CONFIG_QUICK)
        list(APPEND QT_LIBRARIES Qt6::Quick Qt6::Qml)
    endif()
elseif(QT5)
    find_package(Qt5 COMPONENTS Core Gui Widgets Network Xml)
    if(NOT Qt5_FOUND)
        message(FATAL_ERROR 
            "\n"
            "Qt5 not found!\n"
            "\n"
            "Please specify Qt installation path using one of these methods:\n"
            "  1. Set CMAKE_PREFIX_PATH:\n"
            "     cmake -DCMAKE_PREFIX_PATH=/path/to/qt/5.x.x/gcc_64 ..\n"
            "  2. Set Qt5_DIR:\n"
            "     cmake -DQt5_DIR=/path/to/qt/5.x.x/gcc_64/lib/cmake/Qt5 ..\n"
            "  3. Set environment variable:\n"
            "     export CMAKE_PREFIX_PATH=/path/to/qt/5.x.x/gcc_64\n"
            "\n"
            "Common Qt5 paths:\n"
            "  - Linux: /opt/Qt5/5.15.2/gcc_64 or ~/Qt/5.15.2/gcc_64\n"
            "  - macOS: /usr/local/opt/qt@5 or ~/Qt/5.15.2/clang_64\n"
            "  - Windows: C:/Qt/5.15.2/msvc2019_64\n"
            "\n"
            "For VSCode CMake extension, create .vscode/settings.json:\n"
            "{\n"
            "  \"cmake.configureSettings\": {\n"
            "    \"CMAKE_PREFIX_PATH\": \"/path/to/qt/5.15.2/gcc_64\"\n"
            "  }\n"
            "}\n"
        )
    endif()
    
    if(WD_CONFIG_QUICK)
        find_package(Qt5 REQUIRED COMPONENTS Quick Qml)
    endif()
    if(WD_CONFIG_WEBKIT)
        find_package(Qt5 COMPONENTS WebKit WebKitWidgets)
    endif()
    
    get_target_property(QT_QMAKE_EXECUTABLE Qt5::qmake IMPORTED_LOCATION)
    get_filename_component(QT_BIN_DIR "${QT_QMAKE_EXECUTABLE}" DIRECTORY)
    set(QT_MOC_EXECUTABLE "${QT_BIN_DIR}/moc")
    set(QT_UIC_EXECUTABLE "${QT_BIN_DIR}/uic")
    set(QT_RCC_EXECUTABLE "${QT_BIN_DIR}/rcc")
    
    set(QT_LIBRARIES Qt5::Core Qt5::Gui Qt5::Widgets Qt5::Network Qt5::Xml)
    if(WD_CONFIG_QUICK)
        list(APPEND QT_LIBRARIES Qt5::Quick Qt5::Qml)
    endif()
endif()

# Set automoc, autouic, autorcc
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Common definitions
add_compile_definitions(
    QT_NO_DEBUG
    QT_GUI_LIB
    QT_CORE_LIB
    QT_SHARED
    QT_NO_OPENGL
)

# Platform-specific settings
if(LINUX OR ANDROID)
    add_compile_definitions(
        __STDC_FORMAT_MACROS
        OS_POSIX
    )
    add_compile_options(
        -fPIC
        -Wall
        -W
        -Wno-unused-parameter
        -std=gnu++20
    )
    
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-O0 -g)
    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(-O3)
        add_compile_definitions(NDEBUG)
    elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        add_compile_options(-O3 -g)
    endif()
endif()

if(WIN32)
    add_compile_definitions(
        _WIN32
        WIN32
        OS_WIN
        NOMINMAX
        _UNICODE
        _WINSOCKAPI_
    )
endif()

if(ANDROID)
    add_compile_definitions(
        ANDROID
        _GLIBCXX_PERMIT_BACKWARD_HASH
    )
endif()

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/inc
    ${CMAKE_SOURCE_DIR}/src
)

# Subdirectories
add_subdirectory(src/base)
add_subdirectory(src/webdriver)
add_subdirectory(src/webdriver/extension_qt)

if(BUILD_TESTS)
    add_subdirectory(src/Test)
endif()

# Installation
install(DIRECTORY inc/ DESTINATION include/qtwebdriver)
