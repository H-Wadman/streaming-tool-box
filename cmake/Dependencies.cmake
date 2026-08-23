include_guard(GLOBAL)

find_package(
  FFmpeg
  REQUIRED
  COMPONENTS ${STREAMINGTOOLBOX_FFMPEG_REQUIRED_COMPONENTS}
)

if(BUILD_TESTING)
  option(
    STREAMINGTOOLBOX_ALLOW_GTEST_DOWNLOAD
    "Allow FetchContent to download GoogleTest when no system package is found"
    ${PROJECT_IS_TOP_LEVEL}
  )

  set(
    STREAMINGTOOLBOX_GTEST_GIT_TAG
    "6910c9d9165801d8827d628cb72eb7ea9dd538c5"
    CACHE STRING
    "Pinned GoogleTest commit used by the FetchContent fallback"
  )

  find_package(GTest CONFIG QUIET)
  if(NOT TARGET GTest::gtest_main)
    find_package(GTest MODULE QUIET)
  endif()

  if(NOT TARGET GTest::gtest_main)
    if(NOT STREAMINGTOOLBOX_ALLOW_GTEST_DOWNLOAD)
      message(
        FATAL_ERROR
        "GoogleTest was not found and STREAMINGTOOLBOX_ALLOW_GTEST_DOWNLOAD is OFF. "
        "Install a GTest development package or enable the FetchContent fallback."
      )
    endif()

    include(FetchContent)

    set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of the GoogleTest dependency" FORCE)
    set(BUILD_GMOCK OFF CACHE BOOL "Disable GoogleMock for StreamingToolBox" FORCE)
    set(gtest_build_tests OFF CACHE BOOL "Disable GoogleTest's own tests" FORCE)

    FetchContent_Declare(
      googletest
      GIT_REPOSITORY https://github.com/google/googletest.git
      GIT_TAG "${STREAMINGTOOLBOX_GTEST_GIT_TAG}"
    )
    FetchContent_MakeAvailable(googletest)
  endif()

  if(NOT TARGET GTest::gtest_main)
    message(
      FATAL_ERROR
      "GoogleTest is required for BUILD_TESTING, but GTest::gtest_main is unavailable "
      "after system-package discovery and the FetchContent fallback."
    )
  endif()
endif()