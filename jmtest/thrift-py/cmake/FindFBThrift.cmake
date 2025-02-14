# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

INCLUDE(FindPackageHandleStandardArgs)

FIND_LIBRARY(THRIFT_CPP2_LIBRARY thriftcpp2)
FIND_PATH(THRIFT_INCLUDE_DIR "thrift/lib/cpp2/gen/client_h.h")

FIND_PACKAGE_HANDLE_STANDARD_ARGS(FBThrift
  REQUIRED_ARGS THRIFT_INCLUDE_DIR THRIFT_CPP2_LIBRARY)
