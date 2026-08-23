include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

set(_streamingtoolbox_ffmpeg_core_components avcodec avformat avutil swscale swresample)
set(_streamingtoolbox_ffmpeg_known_components
  avdevice
  avfilter
  avformat
  avcodec
  postproc
  swresample
  swscale
  avutil
)

if(FFmpeg_FIND_COMPONENTS)
  set(_streamingtoolbox_ffmpeg_requested_components ${FFmpeg_FIND_COMPONENTS})
  set(_streamingtoolbox_ffmpeg_required_components)
  foreach(
    _streamingtoolbox_ffmpeg_requested_component
    IN LISTS _streamingtoolbox_ffmpeg_requested_components
  )
    if(FFmpeg_FIND_REQUIRED_${_streamingtoolbox_ffmpeg_requested_component})
      list(
        APPEND
        _streamingtoolbox_ffmpeg_required_components
        "${_streamingtoolbox_ffmpeg_requested_component}"
      )
    endif()
  endforeach()
else()
  set(_streamingtoolbox_ffmpeg_requested_components ${_streamingtoolbox_ffmpeg_core_components})
  set(
    _streamingtoolbox_ffmpeg_required_components
    ${_streamingtoolbox_ffmpeg_requested_components}
  )
endif()

set(_streamingtoolbox_ffmpeg_targets)
set(_streamingtoolbox_ffmpeg_include_dirs)
set(_streamingtoolbox_ffmpeg_library_dirs)
set(_streamingtoolbox_ffmpeg_versions)

foreach(
  _streamingtoolbox_ffmpeg_requested_component
  IN LISTS _streamingtoolbox_ffmpeg_requested_components
)
  string(
    TOLOWER
    "${_streamingtoolbox_ffmpeg_requested_component}"
    _streamingtoolbox_ffmpeg_component
  )
  if(_streamingtoolbox_ffmpeg_component MATCHES "^lib(avcodec|avformat|avutil|swscale|swresample|avfilter|avdevice|postproc)$")
    string(
      REGEX REPLACE
      "^lib"
      ""
      _streamingtoolbox_ffmpeg_component
      "${_streamingtoolbox_ffmpeg_component}"
    )
  endif()

  list(
    FIND
    _streamingtoolbox_ffmpeg_known_components
    "${_streamingtoolbox_ffmpeg_component}"
    _streamingtoolbox_ffmpeg_component_index
  )

  set(_streamingtoolbox_ffmpeg_component_found FALSE)
  if(_streamingtoolbox_ffmpeg_component_index EQUAL -1)
    set(
      "FFmpeg_${_streamingtoolbox_ffmpeg_requested_component}_FOUND"
      FALSE
    )
    set(
      "FFmpeg_${_streamingtoolbox_ffmpeg_component}_FOUND"
      FALSE
    )
    continue()
  endif()

  string(
    TOUPPER
    "${_streamingtoolbox_ffmpeg_component}"
    _streamingtoolbox_ffmpeg_component_key
  )
  set(
    _streamingtoolbox_ffmpeg_pc_prefix
    "PC_FFMPEG_${_streamingtoolbox_ffmpeg_component_key}"
  )
  set(
    _streamingtoolbox_ffmpeg_pc_name
    "lib${_streamingtoolbox_ffmpeg_component}"
  )

  if(PkgConfig_FOUND)
    pkg_check_modules(
      ${_streamingtoolbox_ffmpeg_pc_prefix}
      QUIET
      IMPORTED_TARGET
      "${_streamingtoolbox_ffmpeg_pc_name}"
    )
  endif()

  set(
    _streamingtoolbox_ffmpeg_include_variable
    "FFmpeg_${_streamingtoolbox_ffmpeg_component_key}_INCLUDE_DIR"
  )
  set(
    _streamingtoolbox_ffmpeg_library_variable
    "FFmpeg_${_streamingtoolbox_ffmpeg_component_key}_LIBRARY"
  )

  find_path(
    ${_streamingtoolbox_ffmpeg_include_variable}
    NAMES "lib${_streamingtoolbox_ffmpeg_component}/${_streamingtoolbox_ffmpeg_component}.h"
    HINTS ${${_streamingtoolbox_ffmpeg_pc_prefix}_INCLUDE_DIRS}
    PATH_SUFFIXES include
  )
  find_library(
    ${_streamingtoolbox_ffmpeg_library_variable}
    NAMES
      "${_streamingtoolbox_ffmpeg_component}"
      "lib${_streamingtoolbox_ffmpeg_component}"
    HINTS ${${_streamingtoolbox_ffmpeg_pc_prefix}_LIBRARY_DIRS}
    PATH_SUFFIXES lib
  )

  set(
    _streamingtoolbox_ffmpeg_include_dir
    "${${_streamingtoolbox_ffmpeg_include_variable}}"
  )
  set(
    _streamingtoolbox_ffmpeg_library
    "${${_streamingtoolbox_ffmpeg_library_variable}}"
  )
  set(
    _streamingtoolbox_ffmpeg_pc_target
    "PkgConfig::${_streamingtoolbox_ffmpeg_pc_prefix}"
  )

  if(
    "${${_streamingtoolbox_ffmpeg_pc_prefix}_FOUND}" AND
    TARGET "${_streamingtoolbox_ffmpeg_pc_target}"
  )
    set(_streamingtoolbox_ffmpeg_component_found TRUE)
    if(NOT TARGET "FFmpeg::${_streamingtoolbox_ffmpeg_component}")
      add_library("FFmpeg::${_streamingtoolbox_ffmpeg_component}" INTERFACE IMPORTED)
      set_property(
        TARGET "FFmpeg::${_streamingtoolbox_ffmpeg_component}"
        PROPERTY INTERFACE_LINK_LIBRARIES
        "${_streamingtoolbox_ffmpeg_pc_target}"
      )
    endif()
  elseif(_streamingtoolbox_ffmpeg_include_dir AND _streamingtoolbox_ffmpeg_library)
    set(_streamingtoolbox_ffmpeg_component_found TRUE)
    if(NOT TARGET "FFmpeg::${_streamingtoolbox_ffmpeg_component}")
      add_library("FFmpeg::${_streamingtoolbox_ffmpeg_component}" UNKNOWN IMPORTED)
      set_target_properties(
        "FFmpeg::${_streamingtoolbox_ffmpeg_component}"
        PROPERTIES
          IMPORTED_LOCATION "${_streamingtoolbox_ffmpeg_library}"
          INTERFACE_INCLUDE_DIRECTORIES "${_streamingtoolbox_ffmpeg_include_dir}"
      )
    endif()
  endif()

  set(
    "FFmpeg_${_streamingtoolbox_ffmpeg_requested_component}_FOUND"
    "${_streamingtoolbox_ffmpeg_component_found}"
  )
  set(
    "FFmpeg_${_streamingtoolbox_ffmpeg_component}_FOUND"
    "${_streamingtoolbox_ffmpeg_component_found}"
  )

  if(_streamingtoolbox_ffmpeg_component_found)
    list(
      APPEND
      _streamingtoolbox_ffmpeg_targets
      "FFmpeg::${_streamingtoolbox_ffmpeg_component}"
    )
    if(_streamingtoolbox_ffmpeg_include_dir)
      list(APPEND _streamingtoolbox_ffmpeg_include_dirs "${_streamingtoolbox_ffmpeg_include_dir}")
    endif()
    list(
      APPEND
      _streamingtoolbox_ffmpeg_include_dirs
      ${${_streamingtoolbox_ffmpeg_pc_prefix}_INCLUDE_DIRS}
    )
    list(
      APPEND
      _streamingtoolbox_ffmpeg_library_dirs
      ${${_streamingtoolbox_ffmpeg_pc_prefix}_LIBRARY_DIRS}
    )
    if(_streamingtoolbox_ffmpeg_library)
      get_filename_component(
        _streamingtoolbox_ffmpeg_library_dir
        "${_streamingtoolbox_ffmpeg_library}"
        DIRECTORY
      )
      list(APPEND _streamingtoolbox_ffmpeg_library_dirs "${_streamingtoolbox_ffmpeg_library_dir}")
    endif()
    if("${${_streamingtoolbox_ffmpeg_pc_prefix}_VERSION}")
      list(
        APPEND
        _streamingtoolbox_ffmpeg_versions
        "${${_streamingtoolbox_ffmpeg_pc_prefix}_VERSION}"
      )
    endif()
  endif()
endforeach()

list(REMOVE_DUPLICATES _streamingtoolbox_ffmpeg_targets)
list(REMOVE_DUPLICATES _streamingtoolbox_ffmpeg_include_dirs)
list(REMOVE_DUPLICATES _streamingtoolbox_ffmpeg_library_dirs)

if(_streamingtoolbox_ffmpeg_versions)
  list(GET _streamingtoolbox_ffmpeg_versions 0 FFmpeg_VERSION)
endif()

set(_streamingtoolbox_ffmpeg_aggregate_targets)
foreach(
  _streamingtoolbox_ffmpeg_known_component
  IN LISTS _streamingtoolbox_ffmpeg_known_components
)
  if(TARGET "FFmpeg::${_streamingtoolbox_ffmpeg_known_component}")
    list(
      APPEND
      _streamingtoolbox_ffmpeg_aggregate_targets
      "FFmpeg::${_streamingtoolbox_ffmpeg_known_component}"
    )
  endif()
endforeach()
list(REMOVE_DUPLICATES _streamingtoolbox_ffmpeg_aggregate_targets)

set(FFmpeg_INCLUDE_DIRS "${_streamingtoolbox_ffmpeg_include_dirs}")
set(FFmpeg_LIBRARY_DIRS "${_streamingtoolbox_ffmpeg_library_dirs}")
set(FFmpeg_LIBRARIES "${_streamingtoolbox_ffmpeg_aggregate_targets}")

if(_streamingtoolbox_ffmpeg_aggregate_targets AND NOT TARGET FFmpeg::FFmpeg)
  add_library(FFmpeg::FFmpeg INTERFACE IMPORTED)
  set_property(
    TARGET FFmpeg::FFmpeg
    PROPERTY INTERFACE_LINK_LIBRARIES
    "${_streamingtoolbox_ffmpeg_aggregate_targets}"
  )
elseif(TARGET FFmpeg::FFmpeg)
  set_property(
    TARGET FFmpeg::FFmpeg
    PROPERTY INTERFACE_LINK_LIBRARIES
    "${_streamingtoolbox_ffmpeg_aggregate_targets}"
  )
endif()

set(_streamingtoolbox_ffmpeg_required_variables)
foreach(
  _streamingtoolbox_ffmpeg_requested_component
  IN LISTS _streamingtoolbox_ffmpeg_required_components
)
  string(
    TOLOWER
    "${_streamingtoolbox_ffmpeg_requested_component}"
    _streamingtoolbox_ffmpeg_component
  )
  if(_streamingtoolbox_ffmpeg_component MATCHES "^lib(avcodec|avformat|avutil|swscale|swresample|avfilter|avdevice|postproc)$")
    string(
      REGEX REPLACE
      "^lib"
      ""
      _streamingtoolbox_ffmpeg_component
      "${_streamingtoolbox_ffmpeg_component}"
    )
  endif()
  list(
    APPEND
    _streamingtoolbox_ffmpeg_required_variables
    "FFmpeg_${_streamingtoolbox_ffmpeg_component}_FOUND"
  )
endforeach()

if(NOT _streamingtoolbox_ffmpeg_required_variables)
  set(FFmpeg_PACKAGE_CHECK TRUE)
  set(_streamingtoolbox_ffmpeg_required_variables FFmpeg_PACKAGE_CHECK)
endif()

find_package_handle_standard_args(
  FFmpeg
  REQUIRED_VARS ${_streamingtoolbox_ffmpeg_required_variables}
  HANDLE_COMPONENTS
  VERSION_VAR FFmpeg_VERSION
)