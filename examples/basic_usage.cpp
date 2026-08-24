#include <StreamingToolBox/StreamingToolBox.hpp>

#include <iostream>

auto main() -> int
{
    std::cout << hw::stb::ffmpeg_avformat_version() << '\n';
    return 0;
}
