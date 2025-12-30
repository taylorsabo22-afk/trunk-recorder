---
sidebar_label: 'Android Install'
sidebar_position: 4
---

# Android Install

This page covers installing Trunk Recorder on Android devices using Termux or building with the Android NDK.

## Prerequisites

Building Trunk Recorder for Android requires:
- Android device with ARM64 or x86_64 architecture
- Android 7.0 (API level 24) or higher recommended
- Sufficient storage space (at least 2GB free)
- OTG USB support for connecting SDR devices

## Method 1: Using Termux (Recommended for most users)

[Termux](https://termux.dev/) is a terminal emulator and Linux environment app for Android that provides a minimal Linux distribution.

### Install Termux

1. Install Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/) (recommended) or [GitHub releases](https://github.com/termux/termux-app/releases)
   - **Note**: The Google Play Store version is deprecated and should not be used

2. Open Termux and update packages:
```bash
pkg update && pkg upgrade
```

### Install Build Dependencies

You can install dependencies manually or use the provided installation script.

#### Option A: Automated Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/TrunkRecorder/trunk-recorder.git
cd trunk-recorder

# Run the Termux installation script
bash install-termux.sh
```

The script will:
- Install all required dependencies
- Configure storage permissions
- Build and install trunk-recorder
- Provide next steps

#### Option B: Manual Installation

Install the required packages in Termux:

```bash
pkg install -y build-essential cmake git boost gnuradio gnuradio-osmosdr libusb curl openssl sox libsndfile
```

**Note**: Some packages may not be available in the default Termux repositories. You may need to build some dependencies from source or use alternative libraries.

### Grant USB Device Access

To use SDR devices with Termux, you need to grant USB permissions:

1. Connect your SDR device via USB OTG adapter
2. Termux should prompt for USB permissions - grant them
3. The device should appear under `/dev/bus/usb/`

### Build Trunk Recorder

Follow the standard Linux build process:

```bash
# Clone the repository
git clone https://github.com/TrunkRecorder/trunk-recorder.git
cd trunk-recorder

# Create build directory
mkdir ../trunk-build
cd ../trunk-build

# Configure and build
cmake ../trunk-recorder
make -j$(nproc)
make install
```

### Running on Android via Termux

After building, create a configuration file or use the provided example:

```bash
# Copy the example Android configuration
cp examples/config-android-termux.json config.json

# Edit it to match your system
nano config.json

# Run trunk-recorder
./trunk-recorder --config=config.json
```

**Note on Storage Paths in Termux:**
- Use `/sdcard/trunk-recorder` for recordings to access them from file managers
- Or use `~/storage/shared/trunk-recorder` after running `termux-setup-storage`
- Ensure the directory exists before running: `mkdir -p /sdcard/trunk-recorder`

**Important Considerations:**
- Performance may be limited compared to desktop systems
- Battery consumption will be high during recording
- Ensure adequate cooling for your device during extended use
- Storage space should be monitored when recording calls

## Method 2: Building with Android NDK

For developers who want to build a standalone Android app or library:

### Prerequisites

- Android NDK r21 or newer
- CMake 3.12 or newer
- Android SDK with API level 24+

### Setup Android NDK

1. Download and install Android NDK from [developer.android.com](https://developer.android.com/ndk/downloads)

2. Set environment variables:
```bash
export ANDROID_NDK=/path/to/android-ndk
export ANDROID_ABI=arm64-v8a  # or armeabi-v7a, x86, x86_64
```

### Cross-Compile Dependencies

You'll need to cross-compile the following dependencies for Android:
- Boost libraries
- GNU Radio
- gr-osmosdr
- libusb
- OpenSSL
- curl

This is a complex process. Consider using a cross-compilation framework like [vcpkg](https://vcpkg.io/) with Android support.

### Configure Build for Android

You can use the provided build script or configure manually.

#### Option A: Using the Build Script (Recommended)

```bash
# Set Android NDK path
export ANDROID_NDK=/path/to/android-ndk-r25c

# Run the build script with options
./build-android.sh --abi arm64-v8a --api-level 24 --jobs 4

# Or with default settings (arm64-v8a, API 24)
./build-android.sh
```

The script supports the following options:
- `--abi`: Target ABI (arm64-v8a, armeabi-v7a, x86, x86_64)
- `--api-level`: Minimum Android API level (default: 24)
- `--jobs`: Number of parallel build jobs
- `--clean`: Clean build directory before building

#### Option B: Manual Configuration

```bash
mkdir build-android
cd build-android

cmake ../trunk-recorder \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=24 \
  -DCMAKE_ANDROID_ARCH_ABI=$ANDROID_ABI \
  -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
  -DCMAKE_ANDROID_STL_TYPE=c++_shared

make -j$(nproc)
```

## Known Limitations on Android

- **SDR Hardware Support**: Limited to devices with proper USB OTG support. Some SDR drivers may not work on Android
- **Performance**: Recording multiple trunked systems simultaneously may be challenging on mobile hardware
- **Power Management**: Android's aggressive power management may interfere with continuous recording
- **Background Processing**: Apps may be killed when running in background. Use wake locks or foreground services
- **File Permissions**: Android's scoped storage may restrict where recordings can be saved

## Troubleshooting

### USB Device Not Detected

1. Ensure OTG adapter is properly connected
2. Check if Termux has USB permissions
3. Try reconnecting the device
4. Check `lsusb` output in Termux

### Build Errors

1. Ensure all dependencies are installed
2. Check that you have enough storage space
3. Try building with fewer parallel jobs: `make -j2` instead of `make -j$(nproc)`

### Permission Denied Errors

Termux may need storage permissions:
```bash
termux-setup-storage
```
Then grant the requested permissions.

### Out of Memory During Build

If compilation fails due to memory constraints:
1. Reduce parallel jobs: `make -j1` or `make -j2`
2. Close other apps to free memory
3. Consider using a device with more RAM

## Performance Tips

1. **Use a cooling solution**: Continuous recording generates heat
2. **Keep device plugged in**: Battery will drain quickly
3. **Monitor storage**: Recordings consume significant space
4. **Use external storage**: Consider using SD card or USB storage for recordings
5. **Optimize configuration**: Reduce number of simultaneous recorders if performance is poor

## Alternative: Remote Recording

For better performance, consider running Trunk Recorder on a dedicated Linux machine and accessing it from Android via:
- SSH (using Termux)
- Web interface (if using OpenMHz or similar)
- Remote desktop connection

## See Also

- [Linux Install Guide](INSTALL-LINUX.md)
- [Configuration Guide](../CONFIGURE.md)
- [Termux Wiki](https://wiki.termux.com/)
