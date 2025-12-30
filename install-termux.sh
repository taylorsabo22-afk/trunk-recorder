#!/data/data/com.termux/files/usr/bin/bash

# trunk-recorder install script for Termux on Android
# Run this script in Termux to install trunk-recorder

set -e

echo "====== Trunk Recorder Installation for Termux ======"
echo ""

# Check if we're running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "ERROR: This script is designed to run in Termux"
    echo "Please install Termux from F-Droid and run this script again"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d trunk-recorder/recorders ]; then
    echo "====== ERROR: trunk-recorder top level directories not found."
    echo "====== You must change to the trunk-recorder top level directory"
    echo "====== before running this script."
    exit 1
fi

install_dependencies() {
    echo "====== Updating package lists ======"
    pkg update
    
    echo "====== Installing build dependencies ======"
    # Install essential build tools
    pkg install -y build-essential cmake git pkg-config
    
    # Install libraries
    pkg install -y boost libcurl openssl libusb sox libsndfile
    
    # Attempt to install GNU Radio and related packages
    # Note: Not all packages may be available in Termux
    echo "====== Attempting to install GNU Radio (may not be available) ======"
    pkg install -y gnuradio gnuradio-osmosdr || {
        echo "WARNING: GNU Radio not available in Termux repositories"
        echo "You may need to build GNU Radio from source"
        echo "See: https://github.com/gnuradio/gnuradio/wiki"
    }
    
    echo "====== Dependencies installation completed ======"
}

build_trunk_recorder() {
    echo "====== Building Trunk Recorder ======"
    
    # Create build directory
    if [ -d build ]; then
        echo "Cleaning existing build directory..."
        rm -rf build
    fi
    
    mkdir build
    cd build
    
    # Configure
    echo "====== Configuring with CMake ======"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$PREFIX
    
    # Build with limited parallelism to avoid OOM on low-memory devices
    CORES=$(nproc)
    if [ $CORES -gt 2 ]; then
        JOBS=2
    else
        JOBS=1
    fi
    
    echo "====== Building with $JOBS parallel jobs ======"
    make -j$JOBS
    
    cd ..
}

install_trunk_recorder() {
    echo "====== Installing Trunk Recorder ======"
    cd build
    make install
    cd ..
    
    echo "====== Installation completed! ======"
}

setup_storage() {
    echo ""
    echo "====== Setting up storage access ======"
    echo "Termux needs storage permissions to save recordings"
    
    if [ ! -d "$HOME/storage" ]; then
        echo "Running termux-setup-storage..."
        termux-setup-storage
        echo "Please grant storage permissions when prompted"
    else
        echo "Storage already set up"
    fi
}

show_next_steps() {
    echo ""
    echo "======================================"
    echo "Installation completed successfully!"
    echo "======================================"
    echo ""
    echo "Next steps:"
    echo "1. Create a config.json file for your system"
    echo "   See: https://trunkrecorder.com/docs/CONFIGURE"
    echo ""
    echo "2. Connect your SDR device via USB OTG"
    echo "   Termux will prompt for USB permissions"
    echo ""
    echo "3. Run trunk-recorder:"
    echo "   trunk-recorder --config=config.json"
    echo ""
    echo "Notes:"
    echo "- Keep your device plugged in (high battery usage)"
    echo "- Ensure adequate cooling during operation"
    echo "- Monitor storage space for recordings"
    echo ""
    echo "For troubleshooting, see:"
    echo "https://trunkrecorder.com/docs/Install/INSTALL-ANDROID"
    echo ""
}

# Main installation flow
echo "This script will install trunk-recorder on Termux"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled"
    exit 0
fi

install_dependencies
setup_storage
build_trunk_recorder
install_trunk_recorder
show_next_steps

echo "====== Installation script completed ======"
