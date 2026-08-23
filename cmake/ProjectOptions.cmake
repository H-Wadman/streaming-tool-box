include_guard(GLOBAL)

include(Sanitizers)

option(
  STREAMINGTOOLBOX_ENABLE_WARNINGS
  "Enable the project's standard compiler warnings"
  ON
)

option(
  STREAMINGTOOLBOX_WARNINGS_AS_ERRORS
  "Treat compiler warnings as errors for project targets"
  OFF
)

option(
  STREAMINGTOOLBOX_ENABLE_CLANG_TIDY
  "Run clang-tidy on project-owned C++ targets"
  OFF
)

set(
  STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE
  ""
  CACHE FILEPATH
  "Path to the clang-tidy executable"
)

if(STREAMINGTOOLBOX_ENABLE_CLANG_TIDY)
  if(NOT STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE)
    find_program(
      _streamingtoolbox_clang_tidy_executable
      NAMES clang-tidy
      DOC "Path to the clang-tidy executable"
    )
    if(_streamingtoolbox_clang_tidy_executable)
      set(
        STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE
        "${_streamingtoolbox_clang_tidy_executable}"
        CACHE FILEPATH
        "Path to the clang-tidy executable"
        FORCE
      )
    endif()
  endif()

  if(NOT STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE)
    message(
      FATAL_ERROR
      "STREAMINGTOOLBOX_ENABLE_CLANG_TIDY is ON, but clang-tidy was not found. "
      "Set STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE to its path."
    )
  endif()
endif()

function(streaming_toolbox_apply_project_options target)
  if(NOT TARGET "${target}")
    message(FATAL_ERROR "Cannot apply project options to unknown target '${target}'.")
  endif()

  target_compile_features("${target}" PUBLIC cxx_std_20)
  set_property(TARGET "${target}" PROPERTY CXX_EXTENSIONS OFF)

  if(STREAMINGTOOLBOX_ENABLE_WARNINGS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
      target_compile_options(
        "${target}"
        PRIVATE
          -Wall
          -Wextra
          -Wpedantic
      )
    endif()
  endif()

  if(STREAMINGTOOLBOX_WARNINGS_AS_ERRORS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
      target_compile_options("${target}" PRIVATE -Werror)
    endif()
  endif()

  if(STREAMINGTOOLBOX_ENABLE_CLANG_TIDY)
    set(_streamingtoolbox_clang_tidy_arguments --allow-no-checks)
    if(STREAMINGTOOLBOX_WARNINGS_AS_ERRORS)
      list(APPEND _streamingtoolbox_clang_tidy_arguments --warnings-as-errors=*)
    endif()
    set_property(
      TARGET "${target}"
      PROPERTY
        CXX_CLANG_TIDY
        "${STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE};${_streamingtoolbox_clang_tidy_arguments}"
    )
  endif()

  streaming_toolbox_apply_sanitizers("${target}")
endfunction()