include_guard(GLOBAL)

include(CheckCXXSourceCompiles)
include(CMakePushCheckState)

option(
  STREAMINGTOOLBOX_ENABLE_ASAN
  "Enable AddressSanitizer for project targets"
  OFF
)

option(
  STREAMINGTOOLBOX_ENABLE_UBSAN
  "Enable UndefinedBehaviorSanitizer for project targets"
  OFF
)

option(
  STREAMINGTOOLBOX_ENABLE_TSAN
  "Enable ThreadSanitizer for project targets"
  OFF
)

option(
  STREAMINGTOOLBOX_ENABLE_MSAN
  "Enable MemorySanitizer for project targets"
  OFF
)

option(
  STREAMINGTOOLBOX_ENABLE_LSAN
  "Enable LeakSanitizer for project targets"
  OFF
)

set(_streamingtoolbox_requested_sanitizers)

if(STREAMINGTOOLBOX_ENABLE_ASAN)
  list(APPEND _streamingtoolbox_requested_sanitizers address)
endif()

if(STREAMINGTOOLBOX_ENABLE_UBSAN)
  list(APPEND _streamingtoolbox_requested_sanitizers undefined)
endif()

if(STREAMINGTOOLBOX_ENABLE_TSAN)
  list(APPEND _streamingtoolbox_requested_sanitizers thread)
endif()

if(STREAMINGTOOLBOX_ENABLE_MSAN)
  list(APPEND _streamingtoolbox_requested_sanitizers memory)
endif()

if(STREAMINGTOOLBOX_ENABLE_LSAN)
  list(APPEND _streamingtoolbox_requested_sanitizers leak)
endif()

if(STREAMINGTOOLBOX_ENABLE_TSAN AND (
    STREAMINGTOOLBOX_ENABLE_ASAN OR
    STREAMINGTOOLBOX_ENABLE_MSAN OR
    STREAMINGTOOLBOX_ENABLE_LSAN
  ))
  message(
    FATAL_ERROR
    "ThreadSanitizer cannot be combined with AddressSanitizer, MemorySanitizer, "
    "or LeakSanitizer."
  )
endif()

if(STREAMINGTOOLBOX_ENABLE_MSAN AND (
    STREAMINGTOOLBOX_ENABLE_ASAN OR
    STREAMINGTOOLBOX_ENABLE_LSAN
  ))
  message(
    FATAL_ERROR
    "MemorySanitizer cannot be combined with AddressSanitizer or LeakSanitizer."
  )
endif()

if(STREAMINGTOOLBOX_ENABLE_LSAN AND STREAMINGTOOLBOX_ENABLE_ASAN)
  message(
    FATAL_ERROR
    "LeakSanitizer is already included by AddressSanitizer on supported Linux "
    "toolchains; enable only one of them."
  )
endif()

if(STREAMINGTOOLBOX_ENABLE_MSAN AND (
    NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR
    NOT CMAKE_SYSTEM_NAME STREQUAL "Linux"
  ))
  message(
    FATAL_ERROR
    "MemorySanitizer requires the upstream Clang compiler on Linux and is not "
    "available for the selected compiler or platform."
  )
endif()

if(STREAMINGTOOLBOX_ENABLE_LSAN AND NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  message(
    FATAL_ERROR
    "Standalone LeakSanitizer is supported by this project only on Linux."
  )
endif()

if(_streamingtoolbox_requested_sanitizers)
  string(
    JOIN
    ","
    _streamingtoolbox_sanitizer_names
    ${_streamingtoolbox_requested_sanitizers}
  )
  set(
    _streamingtoolbox_sanitizer_flag
    "-fsanitize=${_streamingtoolbox_sanitizer_names}"
  )
  string(
    MAKE_C_IDENTIFIER
    "${_streamingtoolbox_sanitizer_flag}"
    _streamingtoolbox_sanitizer_flag_identifier
  )
  set(
    _streamingtoolbox_sanitizer_check
    "STREAMINGTOOLBOX_COMPILER_SUPPORTS_${_streamingtoolbox_sanitizer_flag_identifier}"
  )

  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS "${_streamingtoolbox_sanitizer_flag}")
  set(CMAKE_REQUIRED_LINK_OPTIONS "${_streamingtoolbox_sanitizer_flag}")
  check_cxx_source_compiles(
    "int main() { return 0; }"
    ${_streamingtoolbox_sanitizer_check}
  )
  cmake_pop_check_state()

  if(NOT "${${_streamingtoolbox_sanitizer_check}}")
    message(
      FATAL_ERROR
      "The selected C++ compiler does not support ${_streamingtoolbox_sanitizer_flag}."
    )
  endif()

  set(
    STREAMINGTOOLBOX_ACTIVE_SANITIZERS
    "${_streamingtoolbox_requested_sanitizers}"
    CACHE INTERNAL
    "Sanitizers enabled for StreamingToolBox targets"
  )
  set(
    STREAMINGTOOLBOX_SANITIZER_COMPILE_OPTIONS
    "${_streamingtoolbox_sanitizer_flag}"
    CACHE INTERNAL
    "Sanitizer compile options for StreamingToolBox targets"
  )
  set(
    STREAMINGTOOLBOX_SANITIZER_LINK_OPTIONS
    "${_streamingtoolbox_sanitizer_flag}"
    CACHE INTERNAL
    "Sanitizer link options for StreamingToolBox targets"
  )

  if(
    STREAMINGTOOLBOX_ENABLE_ASAN OR
    STREAMINGTOOLBOX_ENABLE_TSAN OR
    STREAMINGTOOLBOX_ENABLE_MSAN OR
    STREAMINGTOOLBOX_ENABLE_LSAN
  )
    set(
      STREAMINGTOOLBOX_SANITIZER_COMPILE_OPTIONS
      "${STREAMINGTOOLBOX_SANITIZER_COMPILE_OPTIONS};-fno-omit-frame-pointer"
      CACHE INTERNAL
      "Sanitizer compile options for StreamingToolBox targets"
      FORCE
    )
  endif()
else()
  set(
    STREAMINGTOOLBOX_ACTIVE_SANITIZERS
    ""
    CACHE INTERNAL
    "Sanitizers enabled for StreamingToolBox targets"
  )
  set(
    STREAMINGTOOLBOX_SANITIZER_COMPILE_OPTIONS
    ""
    CACHE INTERNAL
    "Sanitizer compile options for StreamingToolBox targets"
  )
  set(
    STREAMINGTOOLBOX_SANITIZER_LINK_OPTIONS
    ""
    CACHE INTERNAL
    "Sanitizer link options for StreamingToolBox targets"
  )
endif()

function(streaming_toolbox_apply_sanitizers target)
  if(NOT TARGET "${target}")
    message(FATAL_ERROR "Cannot apply sanitizers to unknown target '${target}'.")
  endif()

  if(NOT STREAMINGTOOLBOX_ACTIVE_SANITIZERS)
    return()
  endif()

  target_compile_options(
    "${target}"
    PRIVATE
      ${STREAMINGTOOLBOX_SANITIZER_COMPILE_OPTIONS}
  )

  get_target_property(_streamingtoolbox_target_type "${target}" TYPE)
  if(
    _streamingtoolbox_target_type STREQUAL "EXECUTABLE" OR
    _streamingtoolbox_target_type STREQUAL "SHARED_LIBRARY" OR
    _streamingtoolbox_target_type STREQUAL "MODULE_LIBRARY"
  )
    target_link_options(
      "${target}"
      PRIVATE
        ${STREAMINGTOOLBOX_SANITIZER_LINK_OPTIONS}
    )
  endif()
endfunction()