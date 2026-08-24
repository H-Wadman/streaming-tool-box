#pragma once

#include <span>

#include <StreamingToolBox/Export.hpp>

namespace hw::stb
{

STREAMINGTOOLBOX_EXPORT [[nodiscard]] auto ffmpeg_avformat_version() noexcept
    -> unsigned int;

class Stream
{};

class SynchronizedStream
{};

auto synchronize_streams(std::span<const Stream> streams) noexcept
    -> SynchronizedStream;

} //namespace hw::stb
