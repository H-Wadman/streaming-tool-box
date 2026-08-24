#include <StreamingToolBox/StreamingToolBox.hpp>

#include <cstdlib>

auto main() -> int
{
    const auto version = hw::stb::ffmpeg_avformat_version();
    return version > 0U ? EXIT_SUCCESS : EXIT_FAILURE;
}
