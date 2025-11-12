#!/usr/bin/env bash

# CMake build script for QtWebDriver
# Usage: ./build_cmake.sh [output_dir] [build_type] [qt_version]

output_dir=$1
build_type=$2
qt_version=$3

root_dir=$(pwd)

# Set defaults
if [ -z "$output_dir" ]; then
    output_dir="$root_dir/out"
fi

if [ -z "$build_type" ]; then
    build_type="Release"
fi

if [ -z "$qt_version" ]; then
    qt_version="6"
fi

output_dir=$(readlink -m "${output_dir}")
base_output_dir=$(dirname "${output_dir}")

# Ensure output directory exists
mkdir -p "$output_dir"

# Generate wdversion.cc
echo "Generating version info..."
python3 generate_wdversion.py

# Configure CMake
echo "Configuring CMake..."
cd "$output_dir" || exit 1

cmake "$root_dir" \
    -DCMAKE_BUILD_TYPE="$build_type" \
    -DQT_VERSION="$qt_version" \
    -DCMAKE_INSTALL_PREFIX="$output_dir/install" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTS=ON

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed"
    exit 1
fi

# Build
echo "Building..."
cmake --build . --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi

# Install
echo "Installing to $output_dir/install..."
cmake --install .

if [ $? -ne 0 ]; then
    echo "ERROR: Installation failed"
    exit 1
fi

echo "Build completed successfully!"
echo "Binaries: $output_dir/bin"
echo "Libraries: $output_dir/lib"
echo "Installation: $output_dir/install"
