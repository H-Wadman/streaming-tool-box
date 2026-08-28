#include "avformat_utils.hpp"

#include <array>
#include <cassert>
#include <format>
#include <iostream>
#include <memory>
#include <optional>
#include <span>
#include <string>
#include <utility>

extern "C"
{
#include <libavcodec/codec_id.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/error.h>
}

namespace hw::stb
{

namespace
{

auto ffmpeg_error(int error_code) -> std::string
{
    std::array<char, AV_ERROR_MAX_STRING_SIZE> error_message{};
    if (av_strerror(error_code, error_message.data(), error_message.size()) <
        0) {
        return "unknown FFmpeg error";
    }
    return error_message.data();
}


} //namespace

Libavformat_network::Libavformat_network(Libavformat_network&& other) noexcept :
    m_active{other.m_active}
{ other.m_active = false; }

auto Libavformat_network::create() -> std::optional<Libavformat_network>
{
    int const err = avformat_network_init();
    if (err < 0) {
        std::cerr << ffmpeg_error(err) << '\n';
        return std::nullopt;
    }

    return std::optional<Libavformat_network>{Libavformat_network{true}};
}

auto Libavformat_network::operator=(Libavformat_network&& other) noexcept
    -> Libavformat_network&
{
    if (this == &other) { return *this; }
    if (m_active) { avformat_network_deinit(); }

    m_active = std::exchange(other.m_active, false);

    return *this;
}

Libavformat_network::~Libavformat_network()
{
    if (m_active) { avformat_network_deinit(); }
}

Libavformat_network::Libavformat_network(bool active) : m_active{active} {};

auto open_avformat(std::string const& url)
    -> std::unique_ptr<AVFormatContext, AVFormatContext_closer>
{
    AVFormatContext* format_context = nullptr;

    int const error =
        avformat_open_input(&format_context, url.c_str(), nullptr, nullptr);

    if (error != 0) {
        std::cerr << "Could not open RTSP input '" << url
                  << "': " << ffmpeg_error(error) << '\n';

        avformat_close_input(&format_context);
    }

    return std::unique_ptr<AVFormatContext, AVFormatContext_closer>{
        format_context};
}

void print_stream(AVStream const* const stream, std::ostream& out)
{
    auto get_media_type = [](AVMediaType type) -> char const* {
        auto const* const media_type = av_get_media_type_string(type);
        return media_type != nullptr ? media_type : "unknown";
    };

    auto const* const media_type = get_media_type(stream->codecpar->codec_type);
    assert(media_type != nullptr);
    auto const* const codec_name = avcodec_get_name(stream->codecpar->codec_id);
    out << std::format("Stream {}: {}, codec={}, size={}x{}\n", stream->index,
                       media_type, codec_name, stream->codecpar->width,
                       stream->codecpar->height);
}

auto rtsp_stream_connect(std::string const& rtsp_url)
    -> std::unique_ptr<AVFormatContext, AVFormatContext_closer>
{
    assert(rtsp_url.starts_with("rtsp://") || rtsp_url.starts_with("rtsps://"));

    return open_avformat(rtsp_url);
}

/*!
 * \param[inout] Format context containing the streams to print
 * \param[out] Out stream to print to (std::cout by default)
 */
void print_streams(AVFormatContext* format_context, std::ostream& out)
{
    if (format_context == nullptr) { return; }

    int const error = avformat_find_stream_info(format_context, nullptr);
    if (error != 0) { return; }

    auto const streams = std::span<AVStream const* const>{
        format_context->streams, format_context->nb_streams};

    for (auto const* const stream : streams) { print_stream(stream, out); }
}

} //namespace hw::stb
