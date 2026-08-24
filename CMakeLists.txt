cmake_minimum_required(VERSION 3.31)

project(
  StreamingToolBox
  VERSION 0.1.0
  DESCRIPTION "C++ utilities for media streaming workflows"
  LANGUAGES CXX
)

if(NOT DEFINED CMAKE_CXX_EXTENSIONS)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if(NOT UNIX)
  message(FATAL_ERROR "StreamingToolBox currently supports Unix-like platforms only.")
endif()

include(GNUInstallDirs)

option(BUILD_SHARED_LIBS "Build shared libraries instead of static libraries" OFF)

if(NOT DEFINED BUILD_TESTING)
  set(BUILD_TESTING "${PROJECT_IS_TOP_LEVEL}" CACHE BOOL "Build StreamingToolBox tests")
endif()
include(CTest)

option(
  STREAMINGTOOLBOX_BUILD_EXAMPLES
  "Build StreamingToolBox examples"
  ${PROJECT_IS_TOP_LEVEL}
)

set(
  STREAMINGTOOLBOX_INSTALL_CMAKEDIR
  "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
  CACHE PATH
  "Installation directory for StreamingToolBox CMake package files"
)
mark_as_advanced(STREAMINGTOOLBOX_INSTALL_CMAKEDIR)

set(
  STREAMINGTOOLBOX_FFMPEG_REQUIRED_COMPONENTS
  avcodec
  avformat
  avutil
  swscale
  swresample
)

list(PREPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(CMakePackageConfigHelpers)
include(GenerateExportHeader)
include(ProjectOptions)
include(Dependencies)

add_subdirectory(src)

if(BUILD_TESTING)
  enable_testing()
  add_subdirectory(tests)
endif()

if(STREAMINGTOOLBOX_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

set(_streamingtoolbox_build_tree_package_dir "${PROJECT_BINARY_DIR}/cmake")
file(MAKE_DIRECTORY "${_streamingtoolbox_build_tree_package_dir}")

export(
  EXPORT StreamingToolBoxTargets
  FILE "${_streamingtoolbox_build_tree_package_dir}/StreamingToolBoxTargets.cmake"
  NAMESPACE StreamingToolBox::
)

configure_file(
  "${PROJECT_SOURCE_DIR}/cmake/StreamingToolBoxBuildTreeConfig.cmake.in"
  "${_streamingtoolbox_build_tree_package_dir}/StreamingToolBoxConfig.cmake"
  @ONLY
)

configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/StreamingToolBoxConfig.cmake.in"
  "${PROJECT_BINARY_DIR}/StreamingToolBoxConfig.cmake"
  INSTALL_DESTINATION "${STREAMINGTOOLBOX_INSTALL_CMAKEDIR}"
)

write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/StreamingToolBoxConfigVersion.cmake"
  COMPATIBILITY SameMajorVersion
)

install(
  EXPORT StreamingToolBoxTargets
  FILE StreamingToolBoxTargets.cmake
  NAMESPACE StreamingToolBox::
  DESTINATION "${STREAMINGTOOLBOX_INSTALL_CMAKEDIR}"
)

install(
  FILES
    "${PROJECT_BINARY_DIR}/StreamingToolBoxConfig.cmake"
    "${PROJECT_BINARY_DIR}/StreamingToolBoxConfigVersion.cmake"
    "${PROJECT_SOURCE_DIR}/cmake/FindFFmpeg.cmake"
  DESTINATION "${STREAMINGTOOLBOX_INSTALL_CMAKEDIR}"
)