include(GoogleTest)

add_executable(
  StreamingToolBoxTests
  StreamingToolBoxTests.cpp
)

target_link_libraries(
  StreamingToolBoxTests
  PRIVATE
    StreamingToolBox::StreamingToolBox
    GTest::gtest_main
)

streaming_toolbox_apply_project_options(StreamingToolBoxTests)

gtest_discover_tests(
  StreamingToolBoxTests
  DISCOVERY_MODE PRE_TEST
)