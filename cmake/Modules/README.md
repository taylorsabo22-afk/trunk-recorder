# CMake Modules for Trunk Recorder

This directory contains custom CMake find modules for Trunk Recorder dependencies.

## GNU Radio Modules

### FindGnuradio.cmake

Custom CMake module for finding GNU Radio installations. This module is particularly useful for Android and cross-compilation scenarios where GNU Radio's standard CMake configuration files may not be available.

**Features:**
- Uses pkg-config when available
- Falls back to manual library and include directory search
- Supports finding specific GNU Radio components (runtime, analog, blocks, digital, filter, fft, pmt, audio)
- Detects GNU Radio version from header files
- Creates imported targets for GNU Radio 3.8+

**Usage:**
```cmake
find_package(Gnuradio REQUIRED)
find_package(Gnuradio REQUIRED COMPONENTS runtime analog blocks digital filter fft)
```

**Variables set:**
- `Gnuradio_FOUND` - TRUE if GNU Radio was found
- `Gnuradio_VERSION` - Version string (e.g., "3.8.0")
- `Gnuradio_VERSION_MAJOR` - Major version number
- `Gnuradio_VERSION_MINOR` - Minor version number
- `Gnuradio_VERSION_PATCH` - Patch version number
- `GNURADIO_INCLUDE_DIRS` - Include directories
- `GNURADIO_LIBRARIES` - Libraries to link against
- `GNURADIO_<COMPONENT>_FOUND` - TRUE if component was found
- `GNURADIO_<COMPONENT>_LIBRARIES` - Libraries for specific component
- `GNURADIO_<COMPONENT>_INCLUDE_DIRS` - Include dirs for specific component

**Custom paths:**
You can help CMake find GNU Radio by setting:
- `GNURADIO_DIR` environment variable or CMake variable
- `CMAKE_PREFIX_PATH` to include GNU Radio installation prefix

### GrVersion.cmake

Provides version-related utilities for handling different GNU Radio versions.

**Features:**
- Sets up convenience variables for version comparisons
- Provides macros for version checking
- Displays version information during configuration

**Variables set:**
- `GR_VERSION_LESS_3_8` - TRUE if version < 3.8
- `GR_VERSION_3_8_OR_GREATER` - TRUE if version >= 3.8
- `GR_VERSION_3_9_OR_GREATER` - TRUE if version >= 3.9
- `GR_VERSION_3_10_OR_GREATER` - TRUE if version >= 3.10

**Macros provided:**
- `GR_CHECK_VERSION_LESS(version result)` - Check if GNU Radio version is less than specified
- `GR_CHECK_VERSION_GREATER(version result)` - Check if GNU Radio version is greater than specified
- `GR_CHECK_VERSION_EQUAL(version result)` - Check if GNU Radio version equals specified

## Android Compatibility

These modules were specifically created to improve Android compatibility when building Trunk Recorder with the Android NDK or in Termux. They provide fallback mechanisms to locate GNU Radio when standard CMake configuration files are not available.

For Android builds:
1. The modules use pkg-config when available (e.g., in Termux)
2. Fall back to manual search in standard directories
3. Support custom installation paths via `GNURADIO_DIR` or `CMAKE_PREFIX_PATH`

## Other Modules

This directory also contains find modules for other dependencies:
- `FindGnuradioUHD.cmake` - Find GNU Radio UHD component
- `FindGnuradioOsmosdr.cmake` - Find gr-osmosdr
- `FindLibUHD.cmake` - Find UHD library
- `FindLibHackRF.cmake` - Find HackRF library
- And others...

These modules follow similar patterns and provide fallback search mechanisms.
