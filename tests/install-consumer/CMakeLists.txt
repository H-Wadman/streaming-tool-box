cmake_minimum_required(VERSION 3.31)

project(
  StreamingToolBoxInstallConsumer
  LANGUAGES CXX
)

include(CTest)

find_package(StreamingToolBox CONFIG REQUIRED)

add_executable(
  StreamingToolBoxInstallConsumer
  main.cpp
)

target_compile_features(StreamingToolBoxInstallConsumer PRIVATE cxx_std_20)

target_link_libraries(
  StreamingToolBoxInstallConsumer
  PRIVATE
    StreamingToolBox::StreamingToolBox
)

if(BUILD_TESTING)
  add_test(
    NAME StreamingToolBoxInstallConsumerRuns
    COMMAND StreamingToolBoxInstallConsumer
  )
endif()