# - Find GNU Radio
# Find the GNU Radio includes and libraries
#
# This module defines:
#  Gnuradio_FOUND - system has GNU Radio
#  GNURADIO_INCLUDE_DIRS - the GNU Radio include directories
#  GNURADIO_LIBRARIES - Link these to use GNU Radio
#  Gnuradio_VERSION - GNU Radio version string
#  Gnuradio_VERSION_MAJOR - GNU Radio major version
#  Gnuradio_VERSION_MINOR - GNU Radio minor version  
#  Gnuradio_VERSION_PATCH - GNU Radio patch version
#
# Component variables:
#  GNURADIO_RUNTIME_FOUND
#  GNURADIO_RUNTIME_INCLUDE_DIRS
#  GNURADIO_RUNTIME_LIBRARIES
#  GNURADIO_ANALOG_FOUND
#  GNURADIO_ANALOG_INCLUDE_DIRS
#  GNURADIO_ANALOG_LIBRARIES
#  GNURADIO_BLOCKS_FOUND
#  GNURADIO_BLOCKS_INCLUDE_DIRS
#  GNURADIO_BLOCKS_LIBRARIES
#  GNURADIO_DIGITAL_FOUND
#  GNURADIO_DIGITAL_INCLUDE_DIRS
#  GNURADIO_DIGITAL_LIBRARIES
#  GNURADIO_FILTER_FOUND
#  GNURADIO_FILTER_INCLUDE_DIRS
#  GNURADIO_FILTER_LIBRARIES
#  GNURADIO_FFT_FOUND
#  GNURADIO_FFT_INCLUDE_DIRS
#  GNURADIO_FFT_LIBRARIES
#  GNURADIO_PMT_FOUND
#  GNURADIO_PMT_INCLUDE_DIRS
#  GNURADIO_PMT_LIBRARIES
#  GNURADIO_AUDIO_FOUND
#  GNURADIO_AUDIO_INCLUDE_DIRS
#  GNURADIO_AUDIO_LIBRARIES

include(FindPkgConfig)

# First try to find GNU Radio using pkg-config
if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_GNURADIO gnuradio-runtime)
endif()

# Find the GNU Radio include directory
find_path(GNURADIO_INCLUDE_DIR
    NAMES gnuradio/top_block.h
    HINTS ${PC_GNURADIO_INCLUDEDIR}
          ${PC_GNURADIO_INCLUDE_DIRS}
          $ENV{GNURADIO_DIR}/include
    PATHS /usr/local/include
          /usr/include
          ${CMAKE_INSTALL_PREFIX}/include
)

# Extract version from constants.h or api.h
if(GNURADIO_INCLUDE_DIR AND EXISTS "${GNURADIO_INCLUDE_DIR}/gnuradio/attributes.h")
    file(READ "${GNURADIO_INCLUDE_DIR}/gnuradio/attributes.h" _gnuradio_version_content)
    
    # Try to extract version - format varies by GNU Radio version
    string(REGEX MATCH "#define GNURADIO_VERSION \"([0-9]+)\\.([0-9]+)\\.([0-9]+)" 
           _gnuradio_version_match "${_gnuradio_version_content}")
    
    if(_gnuradio_version_match)
        set(Gnuradio_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Gnuradio_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Gnuradio_VERSION_PATCH "${CMAKE_MATCH_3}")
        set(Gnuradio_VERSION "${Gnuradio_VERSION_MAJOR}.${Gnuradio_VERSION_MINOR}.${Gnuradio_VERSION_PATCH}")
    endif()
endif()

# If version not found in attributes.h, try other methods
if(NOT Gnuradio_VERSION AND PC_GNURADIO_VERSION)
    set(Gnuradio_VERSION ${PC_GNURADIO_VERSION})
    string(REPLACE "." ";" _version_list ${Gnuradio_VERSION})
    list(GET _version_list 0 Gnuradio_VERSION_MAJOR)
    list(GET _version_list 1 Gnuradio_VERSION_MINOR)
    list(LENGTH _version_list _version_length)
    if(_version_length GREATER 2)
        list(GET _version_list 2 Gnuradio_VERSION_PATCH)
    else()
        set(Gnuradio_VERSION_PATCH "0")
    endif()
endif()

# Set default version if still not found
if(NOT Gnuradio_VERSION)
    set(Gnuradio_VERSION "3.8.0")
    set(Gnuradio_VERSION_MAJOR "3")
    set(Gnuradio_VERSION_MINOR "8")
    set(Gnuradio_VERSION_PATCH "0")
    message(WARNING "Could not determine GNU Radio version, assuming ${Gnuradio_VERSION}")
endif()

# Define component names and their library names
set(_gnuradio_components
    runtime
    analog
    blocks
    digital
    filter
    fft
    pmt
    audio
)

# Find each component
foreach(_comp ${_gnuradio_components})
    string(TOUPPER ${_comp} _comp_upper)
    
    # Use pkg-config for this component
    if(PKG_CONFIG_FOUND)
        pkg_check_modules(PC_GNURADIO_${_comp_upper} gnuradio-${_comp})
    endif()
    
    # Find include directory for this component
    find_path(GNURADIO_${_comp_upper}_INCLUDE_DIR
        NAMES gnuradio/${_comp}/api.h
        HINTS ${PC_GNURADIO_${_comp_upper}_INCLUDEDIR}
              ${PC_GNURADIO_${_comp_upper}_INCLUDE_DIRS}
              ${GNURADIO_INCLUDE_DIR}
              $ENV{GNURADIO_DIR}/include
        PATHS /usr/local/include
              /usr/include
              ${CMAKE_INSTALL_PREFIX}/include
    )
    
    # Find library for this component
    find_library(GNURADIO_${_comp_upper}_LIBRARY
        NAMES gnuradio-${_comp}
        HINTS ${PC_GNURADIO_${_comp_upper}_LIBDIR}
              ${PC_GNURADIO_${_comp_upper}_LIBRARY_DIRS}
              $ENV{GNURADIO_DIR}/lib
        PATHS /usr/local/lib
              /usr/local/lib64
              /usr/lib
              /usr/lib64
              ${CMAKE_INSTALL_PREFIX}/lib
              ${CMAKE_INSTALL_PREFIX}/lib64
    )
    
    # Set component-specific variables
    if(GNURADIO_${_comp_upper}_INCLUDE_DIR AND GNURADIO_${_comp_upper}_LIBRARY)
        set(GNURADIO_${_comp_upper}_FOUND TRUE)
        set(GNURADIO_${_comp_upper}_INCLUDE_DIRS ${GNURADIO_${_comp_upper}_INCLUDE_DIR})
        set(GNURADIO_${_comp_upper}_LIBRARIES ${GNURADIO_${_comp_upper}_LIBRARY})
        mark_as_advanced(GNURADIO_${_comp_upper}_INCLUDE_DIR GNURADIO_${_comp_upper}_LIBRARY)
    else()
        set(GNURADIO_${_comp_upper}_FOUND FALSE)
    endif()
endforeach()

# Handle required components
set(_gnuradio_required_vars GNURADIO_INCLUDE_DIR)

if(Gnuradio_FIND_COMPONENTS)
    foreach(_comp ${Gnuradio_FIND_COMPONENTS})
        string(TOUPPER ${_comp} _comp_upper)
        list(APPEND _gnuradio_required_vars GNURADIO_${_comp_upper}_LIBRARY)
        
        if(Gnuradio_FIND_REQUIRED_${_comp} AND NOT GNURADIO_${_comp_upper}_FOUND)
            message(FATAL_ERROR "Required GNU Radio component '${_comp}' not found")
        endif()
    endforeach()
else()
    # If no components specified, at least require runtime
    list(APPEND _gnuradio_required_vars GNURADIO_RUNTIME_LIBRARY)
endif()

# Set aggregate include dirs and libraries
set(GNURADIO_INCLUDE_DIRS ${GNURADIO_INCLUDE_DIR})
set(GNURADIO_LIBRARIES "")

foreach(_comp ${_gnuradio_components})
    string(TOUPPER ${_comp} _comp_upper)
    if(GNURADIO_${_comp_upper}_FOUND)
        list(APPEND GNURADIO_INCLUDE_DIRS ${GNURADIO_${_comp_upper}_INCLUDE_DIRS})
        list(APPEND GNURADIO_LIBRARIES ${GNURADIO_${_comp_upper}_LIBRARIES})
    endif()
endforeach()

# Remove duplicates
if(GNURADIO_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES GNURADIO_INCLUDE_DIRS)
endif()

if(GNURADIO_LIBRARIES)
    list(REMOVE_DUPLICATES GNURADIO_LIBRARIES)
endif()

# Handle standard arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Gnuradio
    REQUIRED_VARS ${_gnuradio_required_vars}
    VERSION_VAR Gnuradio_VERSION
)

# Create imported targets for GNU Radio 3.8+
if(Gnuradio_FOUND AND NOT TARGET gnuradio::gnuradio-runtime)
    if(NOT Gnuradio_VERSION VERSION_LESS "3.8")
        foreach(_comp ${_gnuradio_components})
            string(TOUPPER ${_comp} _comp_upper)
            if(GNURADIO_${_comp_upper}_FOUND AND NOT TARGET gnuradio::gnuradio-${_comp})
                add_library(gnuradio::gnuradio-${_comp} UNKNOWN IMPORTED)
                set_target_properties(gnuradio::gnuradio-${_comp} PROPERTIES
                    IMPORTED_LOCATION "${GNURADIO_${_comp_upper}_LIBRARY}"
                    INTERFACE_INCLUDE_DIRECTORIES "${GNURADIO_${_comp_upper}_INCLUDE_DIRS}"
                )
            endif()
        endforeach()
    endif()
endif()

mark_as_advanced(
    GNURADIO_INCLUDE_DIR
    GNURADIO_INCLUDE_DIRS
    GNURADIO_LIBRARIES
)
