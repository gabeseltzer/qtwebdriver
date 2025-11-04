cmake_minimum_required(VERSION 3.16)

project(QtWebDriverQt6TestApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

# Create the executable
add_executable(qt6_test_app
    qt6_test_app.cpp
)

# Link Qt6 libraries
target_link_libraries(qt6_test_app
    Qt6::Core
    Qt6::Widgets
)

# Set executable properties
set_target_properties(qt6_test_app PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
