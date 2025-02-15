# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

find_path(LIBSODIUM_INCLUDE_DIR NAMES sodium.h)
mark_as_advanced(LIBSODIUM_INCLUDE_DIR)

find_library(LIBSODIUM_LIBRARY NAMES sodium)
mark_as_advanced(LIBSODIUM_LIBRARY)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  LIBSODIUM
  REQUIRED_VARS LIBSODIUM_LIBRARY LIBSODIUM_INCLUDE_DIR)

if(LIBSODIUM_FOUND)
  set(LIBSODIUM_LIBRARIES ${LIBSODIUM_LIBRARY})
  set(LIBSODIUM_INCLUDE_DIRS ${LIBSODIUM_INCLUDE_DIR})
  message(STATUS "Found Libsodium: ${LIBSODIUM_LIBRARY}")
endif()
