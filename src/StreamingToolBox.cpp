#include <StreamingToolBox/StreamingToolBox.hpp>

#include <libavformat/avformat.h>

namespace streaming_toolbox {

unsigned int ffmpeg_avformat_version() noexcept {
  return avformat_version();
}

}