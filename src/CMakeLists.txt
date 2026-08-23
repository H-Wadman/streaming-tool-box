add_library(
  StreamingToolBox
  StreamingToolBox.cpp
)

add_library(StreamingToolBox::StreamingToolBox ALIAS StreamingToolBox)

file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/generated/StreamingToolBox")
generate_export_header(
  StreamingToolBox
  BASE_NAME STREAMINGTOOLBOX
  EXPORT_FILE_NAME "${PROJECT_BINARY_DIR}/generated/StreamingToolBox/Export.hpp"
)

target_sources(
  StreamingToolBox
  PUBLIC
    FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS
      "${PROJECT_SOURCE_DIR}/include"
      "${PROJECT_BINARY_DIR}/generated"
    FILES
      "${PROJECT_SOURCE_DIR}/include/StreamingToolBox/StreamingToolBox.hpp"
      "${PROJECT_BINARY_DIR}/generated/StreamingToolBox/Export.hpp"
)

target_include_directories(
  StreamingToolBox
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/generated>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_link_libraries(StreamingToolBox PRIVATE FFmpeg::FFmpeg)

set_target_properties(
  StreamingToolBox
  PROPERTIES
    EXPORT_NAME StreamingToolBox
    POSITION_INDEPENDENT_CODE ON
)

if(UNIX)
  set_target_properties(
    StreamingToolBox
    PROPERTIES
      CXX_VISIBILITY_PRESET hidden
      VISIBILITY_INLINES_HIDDEN YES
  )
endif()

streaming_toolbox_apply_project_options(StreamingToolBox)

install(
  TARGETS StreamingToolBox
  EXPORT StreamingToolBoxTargets
  FILE_SET public_headers DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)