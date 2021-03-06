# Set up the build environment.
# This should be run before the individual modules are created.

# This file should only run once
IF(DEFINED DCMTK_CONFIGURATION_DONE)
  RETURN()
ENDIF(DEFINED DCMTK_CONFIGURATION_DONE)
SET(DCMTK_CONFIGURATION_DONE true)

# Minimum CMake version required
IF(CMAKE_BACKWARDS_COMPATIBILITY GREATER 3.10.2)
  SET(CMAKE_BACKWARDS_COMPATIBILITY 3.10.2 CACHE STRING "Latest version of CMake when this project was released." FORCE)
ENDIF(CMAKE_BACKWARDS_COMPATIBILITY GREATER 3.10.2)

# CMAKE_BUILD_TYPE is set to value "Release" if none is specified by the
# selected build file generator. For those generators that support multiple
# configuration types (e.g. Debug, Release), CMAKE_CONFIGURATION_TYPES holds
# possible values.  For other generators this value is empty, and for those
# generators the build type is controlled at CMake time by CMAKE_BUILD_TYPE.
# See http://www.cmake.org/pipermail/cmake/2006-January/008065.html for
# details.
#
# To disable the CMAKE_BUILD_TYPE default value, set CMAKE_BUILD_TYPE to value
# "None" during CMake configuration, e.g. use "-DCMAKE_BUILD_TYPE:STRING=None"
# on the command line.  This may be useful if the compiler flags should be
# controlled manually (e.g. as defined in environment variables like CXXFLAGS)
# and no CMake defaults related to the selected configuration type kick in.
IF(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  MESSAGE(STATUS "Setting build type to 'Release' as none was specified.")
  SET(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  SET_PROPERTY(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
ENDIF(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)


# Basic version information
# (Starting with version 3.5.5, an odd number at the last position indicates
#  a development snapshot and an even number indicates an official release.)
SET(DCMTK_MAJOR_VERSION 3)
SET(DCMTK_MINOR_VERSION 6)
SET(DCMTK_BUILD_VERSION 2)
# The ABI is not guaranteed to be stable between different snapshots/releases,
# so this particular version number is increased for each snapshot or release.
SET(DCMTK_ABI_VERSION 12)

# Package "release" settings (some are currently unused and, therefore, disabled)
SET(DCMTK_PACKAGE_NAME "dcmtk")
SET(DCMTK_PACKAGE_DATE "DEV")
SET(DCMTK_PACKAGE_VERSION "${DCMTK_MAJOR_VERSION}.${DCMTK_MINOR_VERSION}.${DCMTK_BUILD_VERSION}")
SET(DCMTK_PACKAGE_VERSION_NUMBER ${DCMTK_MAJOR_VERSION}${DCMTK_MINOR_VERSION}${DCMTK_BUILD_VERSION})
SET(DCMTK_PACKAGE_VERSION_SUFFIX "+")
#SET(DCMTK_PACKAGE_TARNAME "dcmtk-${DCMTK_PACKAGE_VERSION}")
#SET(DCMTK_PACKAGE_STRING "dcmtk ${DCMTK_PACKAGE_VERSION}")
#SET(DCMTK_PACKAGE_BUGREPORT "bugs@dcmtk.org")
#SET(DCMTK_PACKAGE_URL "http://www.dcmtk.org/")

# Shared library version information
SET(DCMTK_LIBRARY_PROPERTIES VERSION "${DCMTK_PACKAGE_VERSION}" SOVERSION "${DCMTK_ABI_VERSION}")

# General build options and settings
OPTION(BUILD_APPS "Build command line applications and test programs." ON)
OPTION(BUILD_SHARED_LIBS "Build with shared libraries." OFF)
OPTION(BUILD_SINGLE_SHARED_LIBRARY "Build a single DCMTK library." OFF)
MARK_AS_ADVANCED(BUILD_SINGLE_SHARED_LIBRARY)
SET(CMAKE_DEBUG_POSTFIX "" CACHE STRING "Library postfix for debug builds. Usually left blank.")
# add our CMake modules to the module path, but prefer the ones from CMake.
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_ROOT}/Modules" "${CMAKE_CURRENT_SOURCE_DIR}/${DCMTK_CMAKE_INCLUDE}/CMake/")
# newer CMake versions will warn if a module exists in its and the project's module paths, which is now always
# the case since above line adds CMake's module path to the project's one. It, therefore, doesn't matter whether
# we set the policy to OLD or NEW, since in both cases CMake's own module will be preferred. We just set
# the policy to silence the warning.
IF(POLICY CMP0017)
    CMAKE_POLICY(SET CMP0017 NEW)
ENDIF()
IF(BUILD_SINGLE_SHARED_LIBRARY)
  # When we are building a single shared lib, we are building shared libs :-)
  SET(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
ENDIF(BUILD_SINGLE_SHARED_LIBRARY)

# DCMTK build options
OPTION(DCMTK_WITH_TIFF "Configure DCMTK with support for TIFF." ON)
OPTION(DCMTK_WITH_PNG "Configure DCMTK with support for PNG." ON)
OPTION(DCMTK_WITH_XML "Configure DCMTK with support for XML." ON)
OPTION(DCMTK_WITH_ZLIB "Configure DCMTK with support for ZLIB." ON)
OPTION(DCMTK_WITH_OPENSSL "Configure DCMTK with support for OPENSSL." ON)
OPTION(DCMTK_WITH_SNDFILE "Configure DCMTK with support for SNDFILE." ON)
OPTION(DCMTK_WITH_ICONV "Configure DCMTK with support for ICONV." ON)
OPTION(DCMTK_WITH_ICU "Configure DCMTK with support for ICU." ON)
IF(NOT WIN32)
  OPTION(DCMTK_WITH_WRAP "Configure DCMTK with support for WRAP." ON)
ENDIF(NOT WIN32)
OPTION(DCMTK_ENABLE_PRIVATE_TAGS "Configure DCMTK with support for DICOM private tags coming with DCMTK." OFF)
OPTION(DCMTK_WITH_THREADS "Configure DCMTK with support for multi-threading." ON)
OPTION(DCMTK_WITH_DOXYGEN "Build API documentation with DOXYGEN." ON)
OPTION(DCMTK_GENERATE_DOXYGEN_TAGFILE "Generate a tag file with DOXYGEN." OFF)
OPTION(DCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS "Build with wide char file I/O functions." OFF)
OPTION(DCMTK_WIDE_CHAR_MAIN_FUNCTION "Build command line tools with wide char main function." OFF)
OPTION(DCMTK_ENABLE_STL "Enable use of native STL classes and algorithms instead of DCMTK's own implementations." OFF)
OPTION(DCMTK_ENABLE_CXX11 "Enable use of native C++11 features (eg. move semantics)." OFF)

MACRO(DCMTK_INFERABLE_OPTION OPTION DESCRIPTION)
  SET("${OPTION}" INFERRED CACHE STRING "${DESCRIPTION}")
  SET_PROPERTY(CACHE "${OPTION}" PROPERTY STRINGS "INFERRED" "ON" "OFF")
  # currently, all inferable options are advanced options
  MARK_AS_ADVANCED("${OPTION}")
ENDMACRO(DCMTK_INFERABLE_OPTION)

DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_VECTOR "Enable use of STL vector.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_ALGORITHM "Enable use of STL algorithm.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_LIMITS "Enable use of STL limit.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_LIST "Enable use of STL list.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_MAP "Enable use of STL map.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_MEMORY "Enable use of STL memory.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_STACK "Enable use of STL stack.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_STRING "Enable use of STL string.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_TYPE_TRAITS "Enable use of STL type traits.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_TUPLE "Enable use of STL tuple.")
DCMTK_INFERABLE_OPTION(DCMTK_ENABLE_STL_SYSTEM_ERROR "Enable use of STL system_error.")

# Built-in (compiled-in) dictionary enabled on Windows per default, otherwise
# disabled. Loading of external dictionary via run-time is, per default,
# configured the the opposite way since most users won't be interested in using
# the external default dictionary if it is already compiled in.
IF(WIN32 OR MINGW)
  OPTION(DCMTK_ENABLE_BUILTIN_DICTIONARY "Configure DCMTK with compiled-in data dictionary." ON)
  OPTION(DCMTK_ENABLE_EXTERNAL_DICTIONARY "Configure DCMTK to load external dictionary from default path on startup." OFF)
ELSE(WIN32 or MINGW) # built-in dictionary turned off on Unix per default
  OPTION(DCMTK_ENABLE_BUILTIN_DICTIONARY "Configure DCMTK with compiled-in data dictionary." OFF)
  OPTION(DCMTK_ENABLE_EXTERNAL_DICTIONARY "Configure DCMTK to load external dictionary from default path on startup." ON)
ENDIF(WIN32 OR MINGW)
if (NOT DCMTK_ENABLE_EXTERNAL_DICTIONARY AND NOT DCMTK_ENABLE_BUILTIN_DICTIONARY)
  MESSAGE(WARNING "Either external or built-in dictionary should be enabled, otherwise dictionary must be loaded manually on startup!")
ENDIF(NOT DCMTK_ENABLE_EXTERNAL_DICTIONARY AND NOT DCMTK_ENABLE_BUILTIN_DICTIONARY)

# Mark various settings as "advanced"
MARK_AS_ADVANCED(CMAKE_DEBUG_POSTFIX)
MARK_AS_ADVANCED(FORCE EXECUTABLE_OUTPUT_PATH LIBRARY_OUTPUT_PATH)
MARK_AS_ADVANCED(SNDFILE_DIR DCMTK_WITH_SNDFILE) # not yet needed in public DCMTK
MARK_AS_ADVANCED(DCMTK_GENERATE_DOXYGEN_TAGFILE)
IF(NOT WIN32)
  # support for wide char file I/O functions is currently Windows-specific
  MARK_AS_ADVANCED(DCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS)
  # support for wide char main function is Windows-specific
  MARK_AS_ADVANCED(DCMTK_WIDE_CHAR_MAIN_FUNCTION)
ENDIF(NOT WIN32)

ENABLE_TESTING()

#-----------------------------------------------------------------------------
# Include appropriate modules and set required variables for cross compiling
#-----------------------------------------------------------------------------

IF(CMAKE_CROSSCOMPILING)
  IF(WIN32)
    INCLUDE("${DCMTK_CMAKE_INCLUDE}CMake/dcmtkUseWine.cmake")
    DCMTK_SETUP_WINE()
  ELSEIF(ANDROID)
    INCLUDE("${DCMTK_CMAKE_INCLUDE}CMake/dcmtkUseAndroidSDK.cmake")
    # Ensure the configuration variables for the Android device emulator exist in the cache.
    DCMTK_SETUP_ANDROID_EMULATOR()
  ENDIF()
ENDIF(CMAKE_CROSSCOMPILING)

#-----------------------------------------------------------------------------
# Generic utilities used for configuring DCMTK
#-----------------------------------------------------------------------------

INCLUDE("${DCMTK_CMAKE_INCLUDE}CMake/dcmtkMacros.cmake")

#-----------------------------------------------------------------------------
# Prepare external dependencies for cross compiling
# (i.e. start the emulator if required)
#-----------------------------------------------------------------------------

IF(CMAKE_CROSSCOMPILING)
  UNSET(DCMTK_UNIT_TESTS_UNSUPPORTED_WARN_ONCE CACHE)
  IF(ANDROID)
    UNSET(DCMTK_TRY_RUN_ANDROID_RUNTIME_INSTALLED CACHE)
    DCMTK_ANDROID_START_EMULATOR(DCMTK_ANDROID_EMULATOR_INSTANCE)
  ENDIF()
ENDIF(CMAKE_CROSSCOMPILING)

#-----------------------------------------------------------------------------
# Installation sub-directories
#-----------------------------------------------------------------------------

# Set project name variable to package name for GnuInstallDirs
SET(PROJECT_NAME "${DCMTK_PACKAGE_NAME}")
# Provides CMake cache variables with reasonable defaults to create a GNU style installation
# directory structure
INCLUDE(GNUInstallDirs)
# CMake's files (DCMTKTarget.cmake, DCMTKConfigVersion.cmake and DCMTKConfig.cmake) are installed
# to different installation paths under Unix- and Windows-based systems
IF(UNIX)
  SET(DCMTK_INSTALL_CMKDIR "${CMAKE_INSTALL_LIBDIR}/cmake/dcmtk")
ELSEIF(WIN32)
  SET(DCMTK_INSTALL_CMKDIR "cmake")
ENDIF(UNIX)

#-----------------------------------------------------------------------------
# Build directories
#-----------------------------------------------------------------------------
SET(DCMTK_BUILD_CMKDIR "${CMAKE_BINARY_DIR}")

#-----------------------------------------------------------------------------
# Start with clean DCMTKTargets.cmake, filled in GenerateCMakeExports.cmake
#-----------------------------------------------------------------------------
FILE(WRITE "${DCMTK_BUILD_CMKDIR}/DCMTKTargets.cmake" "")

#-----------------------------------------------------------------------------
# Platform-independent settings
#-----------------------------------------------------------------------------

# pass optional build date to compiler
#SET(DCMTK_BUILD_DATE "\\\"YYYY-MM-DD\\\"")
IF(DCMTK_BUILD_DATE)

    IF(COMMAND CMAKE_POLICY)
        # Works around warnings about escaped quotes in ADD_DEFINITIONS statements
        CMAKE_POLICY(SET CMP0005 OLD)
    ENDIF(COMMAND CMAKE_POLICY)

    # Xcode needs one escaping layer more than (as far as we know) everyone else - we gotta go deeper!
    IF(CMAKE_GENERATOR MATCHES Xcode)
        STRING(REPLACE "\\" "\\\\" DCMTK_BUILD_DATE "${DCMTK_BUILD_DATE}")
    ENDIF()
    ADD_DEFINITIONS(-DDCMTK_BUILD_DATE=${DCMTK_BUILD_DATE})
ENDIF(DCMTK_BUILD_DATE)

# make OFString(NULL) safe by default
ADD_DEFINITIONS(-DUSE_NULL_SAFE_OFSTRING)

# tell the DCMTK that we are building the DCMTK
ADD_DEFINITIONS(-DDCMTK_BUILD_IN_PROGRESS)

# build output files in these directories
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

#-----------------------------------------------------------------------------
# Platform-specific settings
#-----------------------------------------------------------------------------

# set project wide flags for compiler and linker

IF(WIN32)
  OPTION(DCMTK_OVERWRITE_WIN32_COMPILER_FLAGS "Overwrite compiler flags with DCMTK's WIN32 package default values." ON)
ELSE(WIN32)
  SET(DCMTK_OVERWRITE_WIN32_COMPILER_FLAGS OFF)
ENDIF(WIN32)

IF(DCMTK_OVERWRITE_WIN32_COMPILER_FLAGS AND NOT BUILD_SHARED_LIBS)

  # settings for Microsoft Visual Studio
  IF(CMAKE_GENERATOR MATCHES "Visual Studio .*")
    # get Visual Studio Version
    STRING(REGEX REPLACE "Visual Studio ([0-9]+).*" "\\1" VS_VERSION "${CMAKE_GENERATOR}")
    # these settings never change even for C or C++
    SET(CMAKE_C_FLAGS_DEBUG "/MTd /Z7 /Od")
    SET(CMAKE_C_FLAGS_RELEASE "/DNDEBUG /MT /O2")
    SET(CMAKE_C_FLAGS_MINSIZEREL "/DNDEBUG /MT /O2")
    SET(CMAKE_C_FLAGS_RELWITHDEBINFO "/DNDEBUG /MTd /Z7 /Od")
    SET(CMAKE_CXX_FLAGS_DEBUG "/MTd /Z7 /Od")
    SET(CMAKE_CXX_FLAGS_RELEASE "/DNDEBUG /MT /O2")
    SET(CMAKE_CXX_FLAGS_MINSIZEREL "/DNDEBUG /MT /O2")
    SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/DNDEBUG /MTd /Z7 /Od")
    # specific settings for the various Visual Studio versions
    IF(VS_VERSION EQUAL 6)
      SET(CMAKE_C_FLAGS "/nologo /W3 /GX /Gy /YX")
      SET(CMAKE_CXX_FLAGS "/nologo /W3 /GX /Gy /YX /Zm500") # /Zm500 increments heap size which is needed on some system to compile templates in dcmimgle
    ENDIF(VS_VERSION EQUAL 6)
    IF(VS_VERSION EQUAL 7)
      SET(CMAKE_C_FLAGS "/nologo /W3 /Gy")
      SET(CMAKE_CXX_FLAGS "/nologo /W3 /Gy")
    ENDIF(VS_VERSION EQUAL 7)
    IF(VS_VERSION GREATER 7)
      SET(CMAKE_C_FLAGS "/nologo /W3 /Gy /EHsc")
      SET(CMAKE_CXX_FLAGS "/nologo /W3 /Gy /EHsc")
    ENDIF(VS_VERSION GREATER 7)
  ENDIF(CMAKE_GENERATOR MATCHES "Visual Studio .*")

  # settings for Borland C++
  IF(CMAKE_GENERATOR MATCHES "Borland Makefiles")
    # further settings required? not tested for a very long time!
    SET(CMAKE_STANDARD_LIBRARIES "import32.lib cw32mt.lib")
  ENDIF(CMAKE_GENERATOR MATCHES "Borland Makefiles")

ENDIF(DCMTK_OVERWRITE_WIN32_COMPILER_FLAGS AND NOT BUILD_SHARED_LIBS)

IF(BUILD_SHARED_LIBS)
  SET(DCMTK_SHARED ON)
  IF(BUILD_SINGLE_SHARED_LIBRARY)
    # We can't build apps, because there is no way to tell CMake to link apps
    # against the library.
    SET(BUILD_APPS OFF CACHE BOOL "" FORCE)
    # We are building static code that can be used in a shared lib
    SET(DCMTK_BUILD_SINGLE_SHARED_LIBRARY ON)
    # Make CMake build object libraries. They are just a list of object files
    # which aren't linked together yet.
    SET(DCMTK_LIBRARY_TYPE OBJECT)
    # Static and shared libraries can have dependencies in CMake. Object
    # libraries cannot. Since CMake saves dependencies in its cache, we have to
    # make sure that it doesn't get confused when a "normal" library turns into
    # an object library. Do this via a suffix.
    SET(DCMTK_LIBRARY_SUFFIX _obj)
    # This uses object libraries which are new in CMake 2.8.8
    CMAKE_MINIMUM_REQUIRED(VERSION 2.8.8)
  ENDIF(BUILD_SINGLE_SHARED_LIBRARY)

  OPTION(USE_COMPILER_HIDDEN_VISIBILITY
      "Use hidden visibility support if available" ON)
  MARK_AS_ADVANCED(USE_COMPILER_HIDDEN_VISIBILITY)

  INCLUDE(CheckCXXCompilerFlag)
  CHECK_CXX_COMPILER_FLAG("-fvisibility=hidden" GXX_SUPPORTS_VISIBILITY)
  # This "NOT WIN32" is needed due to a CMake bug that was fixed in
  # CMake 2.8.x. CHECK_CXX_COMPILER_FLAG() always says "ok" with MSC.
  IF(GXX_SUPPORTS_VISIBILITY AND USE_COMPILER_HIDDEN_VISIBILITY AND NOT WIN32)
    SET(HAVE_HIDDEN_VISIBILITY ON)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
  ELSE(GXX_SUPPORTS_VISIBILITY AND USE_COMPILER_HIDDEN_VISIBILITY AND NOT WIN32)
    SET(HAVE_HIDDEN_VISIBILITY)
  ENDIF(GXX_SUPPORTS_VISIBILITY AND USE_COMPILER_HIDDEN_VISIBILITY AND NOT WIN32)
ENDIF(BUILD_SHARED_LIBS)

IF(WIN32)   # special handling for Windows systems

  IF(MINGW)
    # Avoid auto-importing warnings on MinGW
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--enable-auto-import")
  ELSE(MINGW)
    IF(NOT BORLAND)
      IF(NOT CYGWIN)
        # Disable min() and max() macros pre-defined by Microsoft. We define our own
        # version in oflimits.h and on Windows that could result in name clashes in
        # Visual Studio.
        ADD_DEFINITIONS(-DNOMINMAX)
        # On Visual Studio 8 MS deprecated C. This removes all 1.276E1265 security warnings.
        IF(NOT DCMTK_ENABLE_VISUAL_STUDIO_DEPRECATED_C_WARNINGS)
          ADD_DEFINITIONS(
            -D_CRT_FAR_MAPPINGS_NO_DEPRECATE
            -D_CRT_IS_WCTYPE_NO_DEPRECATE
            -D_CRT_MANAGED_FP_NO_DEPRECATE
            -D_CRT_NONSTDC_NO_DEPRECATE
            -D_CRT_SECURE_NO_DEPRECATE
            -D_CRT_SECURE_NO_DEPRECATE_GLOBALS
            -D_CRT_SETERRORMODE_BEEP_SLEEP_NO_DEPRECATE
            -D_CRT_TIME_FUNCTIONS_NO_DEPRECATE
            -D_CRT_VCCLRIT_NO_DEPRECATE
            -D_SCL_SECURE_NO_DEPRECATE
            )
        ENDIF(NOT DCMTK_ENABLE_VISUAL_STUDIO_DEPRECATED_C_WARNINGS)
      ENDIF(NOT CYGWIN)
    ENDIF(NOT BORLAND)
  ENDIF(MINGW)

ELSE(WIN32)   # ... for non-Windows systems

  # Compiler flags for Mac OS X
  IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE -D_DARWIN_C_SOURCE")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE -D_DARWIN_C_SOURCE")
  # Compiler flags for NetBSD
  ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "NetBSD")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_XOPEN_SOURCE_EXTENDED -D_XOPEN_SOURCE=500 -D_NETBSD_SOURCE -D_DEFAULT_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE -D_POSIX_C_SOURCE=199506L")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_XOPEN_SOURCE_EXTENDED -D_XOPEN_SOURCE=500 -D_NETBSD_SOURCE -D_DEFAULT_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE -D_POSIX_C_SOURCE=199506L")
  # Solaris, FreeBSD and newer versions of OpenBSD fail with these flags
  ELSEIF(NOT ${CMAKE_SYSTEM_NAME} MATCHES "SunOS" AND NOT ${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD" AND (NOT ${CMAKE_SYSTEM_NAME} MATCHES "OpenBSD" OR ${CMAKE_SYSTEM_VERSION} VERSION_LESS 4))
    # Compiler flags for all other non-Windows systems
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_XOPEN_SOURCE_EXTENDED -D_XOPEN_SOURCE=500 -D_BSD_SOURCE -D_DEFAULT_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE -D_POSIX_C_SOURCE=199506L")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_XOPEN_SOURCE_EXTENDED -D_XOPEN_SOURCE=500 -D_BSD_SOURCE -D_DEFAULT_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE -D_POSIX_C_SOURCE=199506L")
  ENDIF()

  OPTION(DCMTK_FORCE_FPIC_ON_UNIX "Add -fPIC compiler flag on unix 64 bit machines to allow linking from dynamic libraries even if DCMTK is built statically" OFF)
  MARK_AS_ADVANCED(DCMTK_FORCE_FPIC_ON_UNIX)

  # Setting for IA64 / x86_64 which needs -fPIC compiler flag required for shared library build on these platforms
  IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" AND UNIX AND DCMTK_FORCE_FPIC_ON_UNIX)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  ENDIF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" AND UNIX AND DCMTK_FORCE_FPIC_ON_UNIX)

ENDIF(WIN32)

# define libraries and object files that must be linked to most Windows applications
IF(WIN32)
  SET(WIN32_STD_LIBRARIES iphlpapi ws2_32 netapi32 wsock32)
  IF(NOT DEFINED MINGW)
    # additional object file needed for wildcard expansion; for wchar_t* support, use 'wsetargv'
    SET(WIN32_STD_OBJECTS setargv)
  ENDIF(NOT DEFINED MINGW)
  # settings for Borland C++
  IF(CMAKE_CXX_COMPILER MATCHES bcc32)
    # to be checked: further settings required?
    SET(CMAKE_STANDARD_LIBRARIES "import32.lib cw32mt.lib")
  ENDIF(CMAKE_CXX_COMPILER MATCHES bcc32)
ENDIF(WIN32)

# add definition of "DEBUG" to debug mode (since CMake does not do this automatically)
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG")
SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

# determine which flags are required to enable C++11 features (if any)
IF(NOT DEFINED DCMTK_CXX11_FLAGS)
  IF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    SET(DCMTK_CXX11_FLAGS "-std=c++11")
  ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
    IF(CMAKE_HOST_WIN32)
      SET(DCMTK_CXX11_FLAGS "/Qstd=c++11")
    ELSE()
      SET(DCMTK_CXX11_FLAGS "-std=c++11")
    ENDIF()
  ELSE()
    SET(DCMTK_CXX11_FLAGS "")
  ENDIF()
  SET(DCMTK_CXX11_FLAGS "${DCMTK_CXX11_FLAGS}" CACHE STRING "The flags to add to CMAKE_CXX_FLAGS for enabling C++11 (if any).")
  MARK_AS_ADVANCED(DCMTK_CXX11_FLAGS)
ENDIF(NOT DEFINED DCMTK_CXX11_FLAGS)

#-----------------------------------------------------------------------------
# Third party libraries
#-----------------------------------------------------------------------------

INCLUDE(${DCMTK_CMAKE_INCLUDE}CMake/3rdparty.cmake)

#-----------------------------------------------------------------------------
# DCMTK libraries
#-----------------------------------------------------------------------------

INCLUDE(${DCMTK_CMAKE_INCLUDE}CMake/GenerateDCMTKConfigure.cmake)

#-----------------------------------------------------------------------------
# Dart configuration (disabled per default)
#-----------------------------------------------------------------------------

# Includes build targets Experimental, Nightly and Continuous which are the standard
# groups pre-configured in Dashboard. In CTest these groups are called "Tracks".
#
# INCLUDE(${CMAKE_ROOT}/Modules/Dart.cmake)
# IF(BUILD_TESTING)
#   ENABLE_TESTING()
# ENDIF(BUILD_TESTING)

#-----------------------------------------------------------------------------
# Thread support
#-----------------------------------------------------------------------------

# See dcmtk/config/configure.in
IF(WITH_THREADS)
  ADD_DEFINITIONS(-D_REENTRANT)
  IF(HAVE_PTHREAD_RWLOCK)
    IF(APPLE)
      ADD_DEFINITIONS(-D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -D_BSD_COMPAT -D_OSF_SOURCE)
    ENDIF(APPLE)
    IF("${CMAKE_SYSTEM_NAME}" MATCHES "^IRIX")
      ADD_DEFINITIONS(-D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -D_BSD_COMPAT)
    ENDIF("${CMAKE_SYSTEM_NAME}" MATCHES "^IRIX")
  ENDIF(HAVE_PTHREAD_RWLOCK)

  IF(HAVE_PTHREAD_H)
    CHECK_LIBRARY_EXISTS(pthread pthread_key_create "" HAVE_LIBPTHREAD)
    IF(HAVE_LIBPTHREAD)
      SET(THREAD_LIBS pthread)
    ENDIF(HAVE_LIBPTHREAD)
    CHECK_LIBRARY_EXISTS(rt sem_init "" HAVE_LIBRT)
    IF(HAVE_LIBRT)
      SET(THREAD_LIBS ${THREAD_LIBS} rt)
    ENDIF(HAVE_LIBRT)
  ENDIF(HAVE_PTHREAD_H)
ENDIF(WITH_THREADS)

#-----------------------------------------------------------------------------
# Test for socket libraries if needed (Solaris)
#-----------------------------------------------------------------------------

SET(SOCKET_LIBS)

FUNCTION(DCMTK_TEST_SOCKET_LIBRARY NAME SYMBOL)
  STRING(TOUPPER "${NAME}" VARNAME)
  CHECK_LIBRARY_EXISTS("${NAME}" "main" "" "HAVE_LIB${VARNAME}_MAIN")
  IF(NOT HAVE_LIB${VARNAME}_MAIN)
    CHECK_LIBRARY_EXISTS("${NAME}" "${SYMBOL}" "" "HAVE_LIB${VARNAME}")
  ENDIF(NOT HAVE_LIB${VARNAME}_MAIN)
  IF(HAVE_LIB${VARNAME} OR HAVE_LIB${VARNAME}_MAIN)
    LIST(APPEND SOCKET_LIBS "${NAME}")
    SET(SOCKET_LIBS "${SOCKET_LIBS}" PARENT_SCOPE)
  ENDIF(HAVE_LIB${VARNAME} OR HAVE_LIB${VARNAME}_MAIN)
ENDFUNCTION(DCMTK_TEST_SOCKET_LIBRARY)

DCMTK_TEST_SOCKET_LIBRARY(nsl "gethostbyname")
DCMTK_TEST_SOCKET_LIBRARY(socket "socket")

#-----------------------------------------------------------------------------
# Test if SunPro compiler and add features
#-----------------------------------------------------------------------------

IF(CMAKE_CXX_COMPILER_ID STREQUAL SunPro)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -features=tmplrefstatic")
ENDIF()

#-----------------------------------------------------------------------------
# workaround for using the deprecated generator expression $<CONFIGURATION>
# with old CMake versions that do not understand $<CONFIG>
#-----------------------------------------------------------------------------
IF(CMAKE_VERSION VERSION_LESS 3.0.0)
  SET(DCMTK_CONFIG_GENERATOR_EXPRESSION "$<CONFIGURATION>" CACHE INTERNAL "the generator expression to use for retriving the current config")
ELSE()
  SET(DCMTK_CONFIG_GENERATOR_EXPRESSION "$<CONFIG>" CACHE INTERNAL "the generator expression to use for retriving the current config")
ENDIF()
