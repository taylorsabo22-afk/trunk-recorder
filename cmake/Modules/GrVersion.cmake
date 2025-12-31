# - GNU Radio Version Utilities
# This module provides version-related utilities for GNU Radio
#
# It sets up variables based on the detected GNU Radio version
# and can be used to handle version-specific behavior

if(NOT Gnuradio_VERSION)
    message(WARNING "GNU Radio version not set. GrVersion.cmake should be included after finding GNU Radio package.")
    set(Gnuradio_VERSION "3.8.0")
    set(Gnuradio_VERSION_MAJOR "3")
    set(Gnuradio_VERSION_MINOR "8")
    set(Gnuradio_VERSION_PATCH "0")
endif()

# Provide version comparison helpers
macro(GR_CHECK_VERSION_LESS version result)
    if(Gnuradio_VERSION VERSION_LESS ${version})
        set(${result} TRUE)
    else()
        set(${result} FALSE)
    endif()
endmacro()

macro(GR_CHECK_VERSION_GREATER version result)
    if(Gnuradio_VERSION VERSION_GREATER ${version})
        set(${result} TRUE)
    else()
        set(${result} FALSE)
    endif()
endmacro()

macro(GR_CHECK_VERSION_EQUAL version result)
    if(Gnuradio_VERSION VERSION_EQUAL ${version})
        set(${result} TRUE)
    else()
        set(${result} FALSE)
    endif()
endmacro()

# Set convenience variables for common version checks
if(Gnuradio_VERSION VERSION_LESS "3.8")
    set(GR_VERSION_LESS_3_8 TRUE)
else()
    set(GR_VERSION_LESS_3_8 FALSE)
endif()

if(Gnuradio_VERSION VERSION_GREATER_EQUAL "3.8")
    set(GR_VERSION_3_8_OR_GREATER TRUE)
else()
    set(GR_VERSION_3_8_OR_GREATER FALSE)
endif()

if(Gnuradio_VERSION VERSION_GREATER_EQUAL "3.9")
    set(GR_VERSION_3_9_OR_GREATER TRUE)
else()
    set(GR_VERSION_3_9_OR_GREATER FALSE)
endif()

if(Gnuradio_VERSION VERSION_GREATER_EQUAL "3.10")
    set(GR_VERSION_3_10_OR_GREATER TRUE)
else()
    set(GR_VERSION_3_10_OR_GREATER FALSE)
endif()

# Display version information
message(STATUS "GNU Radio Version: ${Gnuradio_VERSION}")
message(STATUS "  Major: ${Gnuradio_VERSION_MAJOR}")
message(STATUS "  Minor: ${Gnuradio_VERSION_MINOR}")
message(STATUS "  Patch: ${Gnuradio_VERSION_PATCH}")
