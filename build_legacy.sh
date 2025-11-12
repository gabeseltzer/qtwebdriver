#!/usr/bin/env bash

# QtWebDriver CMake Build Script
# This script has been updated to use CMake instead of GYP
# For legacy GYP builds, see git history

output_gen=$1
platform=$2
mode=$3
qt_dir=$4

root_dir=$(pwd)

# Set defaults
if [ -z "$output_gen" ]; then
    output_gen="$root_dir/out"
fi

if [ -z "$platform" ]; then
    platform="desktop"
fi

if [ -z "$mode" ]; then
    mode="release"
fi

# Map mode to CMAKE_BUILD_TYPE
case "$mode" in
    debug)
        build_type="Debug"
        ;;
    release)
        build_type="Release"
        ;;
    release_dbg)
        build_type="RelWithDebInfo"
        ;;
    *)
        build_type="Release"
        ;;
esac

# Determine Qt version from qt_dir if provided
qt_version="6"
if [ -n "$qt_dir" ]; then
    if [[ "$qt_dir" == *"qt5"* ]] || [[ "$qt_dir" == *"Qt5"* ]]; then
        qt_version="5"
    fi
fi

output_gen=$(readlink -m "${output_gen}")
OUTPUT_DIR="${output_gen}/${platform}/${mode}"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Generate version info
echo "Generating version info..."
python3 generate_wdversion.py

# Configure and build with CMake
echo "Configuring with CMake..."
cd "$OUTPUT_DIR" || exit 1

cmake_args=(
    "$root_dir"
    "-DCMAKE_BUILD_TYPE=$build_type"
    "-DQT_VERSION=$qt_version"
    "-DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/install"
)

# Add Qt directory if specified
if [ -n "$qt_dir" ]; then
    cmake_args+=("-DCMAKE_PREFIX_PATH=$qt_dir")
fi

cmake "${cmake_args[@]}"
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

# Install/copy files to dist directory
DIST_DIR="${output_gen}/dist/${platform}/${mode}"
mkdir -p "${DIST_DIR}"/{bin,libs,h,Test}

# Copy libraries
cp -f lib/*.a "${DIST_DIR}/libs/" 2>/dev/null
cp -f lib/*.so "${DIST_DIR}/libs/" 2>/dev/null

# Copy headers
cp -rf "$root_dir/inc/"* "${DIST_DIR}/h/" 2>/dev/null
cp -rf "$root_dir/src/Test" "${DIST_DIR}/" 2>/dev/null

# Copy binaries
cp -f bin/* "${DIST_DIR}/bin/" 2>/dev/null

echo "Build completed successfully!"
echo "Output directory: $OUTPUT_DIR"
echo "Distribution directory: $DIST_DIR"
