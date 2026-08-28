include(GoogleTest)

option(
  STREAMINGTOOLBOX_DISABLE_LSAN_FOR_TESTS
  "Disable LeakSanitizer when running tests"
  OFF
)

add_executable(
  StreamingToolBoxTests
  StreamingToolBoxTests.cpp
  avformat_utils_test.cpp
)

target_link_libraries(
  StreamingToolBoxTests
  PRIVATE
    StreamingToolBox::StreamingToolBox
    GTest::gtest_main
)

target_include_directories(
  StreamingToolBoxTests
  PRIVATE
  "${PROJECT_SOURCE_DIR}/src"
)

streaming_toolbox_apply_project_options(StreamingToolBoxTests)

if(STREAMINGTOOLBOX_DISABLE_LSAN_FOR_TESTS)
  if(STREAMINGTOOLBOX_ENABLE_ASAN)
    set(_streamingtoolbox_lsan_environment ASAN_OPTIONS=detect_leaks=0)
  elseif(STREAMINGTOOLBOX_ENABLE_LSAN)
    set(_streamingtoolbox_lsan_environment LSAN_OPTIONS=detect_leaks=0)
  else()
    message(
      WARNING
      "STREAMINGTOOLBOX_DISABLE_LSAN_FOR_TESTS is ON, but LeakSanitizer is "
      "not enabled."
    )
  endif()

  if(_streamingtoolbox_lsan_environment)
    set_property(
      TARGET StreamingToolBoxTests
      PROPERTY
        TEST_LAUNCHER
        "${CMAKE_COMMAND};-E;env;${_streamingtoolbox_lsan_environment}"
    )
  endif()
endif()

gtest_discover_tests(
  StreamingToolBoxTests
  DISCOVERY_MODE PRE_TEST
    DISCOVERY_TIMEOUT 30
)
