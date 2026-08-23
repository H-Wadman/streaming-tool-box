add_executable(
  StreamingToolBoxExample
  basic_usage.cpp
)

target_link_libraries(
  StreamingToolBoxExample
  PRIVATE
    StreamingToolBox::StreamingToolBox
)

streaming_toolbox_apply_project_options(StreamingToolBoxExample)