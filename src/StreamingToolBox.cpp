#include <StreamingToolBox/StreamingToolBox.hpp>

extern "C"
{
#include <libavformat/avformat.h>
}

namespace hw::stb
{

auto ffmpeg_avformat_version() noexcept -> unsigned int
{ return avformat_version(); }

} //namespace hw::stb
