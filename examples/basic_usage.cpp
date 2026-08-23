#include <StreamingToolBox/StreamingToolBox.hpp>

#include <iostream>

int main() {
  std::cout << streaming_toolbox::ffmpeg_avformat_version() << '\n';
  return 0;
}