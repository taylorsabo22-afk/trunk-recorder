#!/bin/bash

# trunk-recorder Android build script using Android NDK
# This script helps configure and build trunk-recorder for Android

set -e

# Check if we're in the right directory
if [ ! -d trunk-recorder/recorders ]; then
    echo "====== ERROR: trunk-recorder top level directories not found."
    echo "====== You must change to the trunk-recorder top level directory"
    echo "====== before running this script."
    exit 1
fi

# Check for required environment variables
check_ndk() {
    if [ -z "$ANDROID_NDK" ] && [ -z "$ANDROID_NDK_ROOT" ]; then
        echo "====== ERROR: ANDROID_NDK or ANDROID_NDK_ROOT environment variable not set"
        echo "====== Please set it to your Android NDK installation path"
        echo "====== Example: export ANDROID_NDK=/path/to/android-ndk-r25c"
        exit 1
    fi
    
    # Use ANDROID_NDK_ROOT if ANDROID_NDK is not set
    if [ -z "$ANDROID_NDK" ]; then
        export ANDROID_NDK=$ANDROID_NDK_ROOT
    fi
    
    if [ ! -d "$ANDROID_NDK" ]; then
        echo "====== ERROR: Android NDK directory not found at: $ANDROID_NDK"
        exit 1
    fi
    
    echo "====== Using Android NDK at: $ANDROID_NDK"
}

# Set default values
ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
ANDROID_API_LEVEL="${ANDROID_API_LEVEL:-24}"
BUILD_DIR="${BUILD_DIR:-build-android-${ANDROID_ABI}}"

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -a, --abi ABI          Android ABI (arm64-v8a, armeabi-v7a, x86, x86_64)"
    echo "                         Default: arm64-v8a"
    echo "  -l, --api-level LEVEL  Android API level (minimum 24)"
    echo "                         Default: 24"
    echo "  -b, --build-dir DIR    Build directory"
    echo "                         Default: build-android-\${ABI}"
    echo "  -j, --jobs N           Number of parallel build jobs"
    echo "                         Default: number of CPU cores"
    echo "  -c, --clean            Clean build directory before building"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  ANDROID_NDK            Path to Android NDK (required)"
    echo "  ANDROID_API_LEVEL      Android API level (optional, default: 24)"
    echo "  ANDROID_ABI            Target Android ABI (optional, default: arm64-v8a)"
    echo ""
    echo "Example:"
    echo "  export ANDROID_NDK=/path/to/android-ndk-r25c"
    echo "  $0 --abi arm64-v8a --api-level 24 --jobs 4"
}

# Parse command line arguments
CLEAN_BUILD=0
JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--abi)
            ANDROID_ABI="$2"
            shift 2
            ;;
        -l|--api-level)
            ANDROID_API_LEVEL="$2"
            shift 2
            ;;
        -b|--build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=1
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate ABI
case "$ANDROID_ABI" in
    arm64-v8a|armeabi-v7a|x86|x86_64)
        echo "====== Target ABI: $ANDROID_ABI"
        ;;
    *)
        echo "====== ERROR: Invalid Android ABI: $ANDROID_ABI"
        echo "====== Supported ABIs: arm64-v8a, armeabi-v7a, x86, x86_64"
        exit 1
        ;;
esac

# Validate API level
if [ "$ANDROID_API_LEVEL" -lt 24 ]; then
    echo "====== WARNING: Android API level $ANDROID_API_LEVEL is below minimum recommended (24)"
    echo "====== Some features may not work correctly"
fi

# Check NDK
check_ndk

# Clean build directory if requested
if [ $CLEAN_BUILD -eq 1 ] && [ -d "$BUILD_DIR" ]; then
    echo "====== Cleaning build directory: $BUILD_DIR"
    rm -rf "$BUILD_DIR"
fi

# Create build directory
echo "====== Creating build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Display configuration
echo "====== Build Configuration ======"
echo "Android NDK: $ANDROID_NDK"
echo "Android ABI: $ANDROID_ABI"
echo "Android API Level: $ANDROID_API_LEVEL"
echo "Build Directory: $BUILD_DIR"
echo "Parallel Jobs: $JOBS"
echo "==============================="

# Configure with CMake
echo "====== Configuring CMake for Android ======"
cmake .. \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=$ANDROID_API_LEVEL \
    -DCMAKE_ANDROID_ARCH_ABI=$ANDROID_ABI \
    -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
    -DCMAKE_ANDROID_STL_TYPE=c++_shared \
    -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_PLATFORM=android-$ANDROID_API_LEVEL

# Build
echo "====== Building trunk-recorder for Android ======"
make -j$JOBS

echo ""
echo "====== Build completed successfully! ======"
echo "Build artifacts are in: $BUILD_DIR"
echo ""
echo "Note: You may need to manually copy required shared libraries"
echo "(.so files) to your Android device along with the executable."
echo ""
echo "To install on device, you can use:"
echo "  adb push trunk-recorder /data/local/tmp/"
echo "  adb shell chmod +x /data/local/tmp/trunk-recorder"
