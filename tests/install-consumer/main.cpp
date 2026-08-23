#include <StreamingToolBox/StreamingToolBox.hpp>

#include <cstdlib>

int main()
{
    const auto version = streaming_toolbox::ffmpeg_avformat_version();
    return version > 0U ? EXIT_SUCCESS : EXIT_FAILURE;
}