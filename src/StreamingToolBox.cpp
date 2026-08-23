#include <StreamingToolBox/StreamingToolBox.hpp>

extern "C"
{
#include <libavformat/avformat.h>
}

namespace streaming_toolbox
{

unsigned int ffmpeg_avformat_version() noexcept { return avformat_version(); }

} //namespace streaming_toolbox