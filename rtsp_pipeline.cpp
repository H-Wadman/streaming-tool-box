#include <array>
#include <iostream>
#include <string>

extern "C"
{
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/error.h>
}

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

} // namespace

auto main() -> int
{
    constexpr auto rtsp_url = "rtsp://127.0.0.1:8554/stream";

    const auto network_error = avformat_network_init();
    if (network_error < 0) {
        std::cerr << "Could not initialize FFmpeg networking: "
                  << ffmpeg_error(network_error) << '\n';
        return 1;
    }

    AVFormatContext* format_context = nullptr;
    const auto cleanup              = [&format_context]() noexcept {
        avformat_close_input(&format_context);
        avformat_network_deinit();
    };

    auto error =
        avformat_open_input(&format_context, rtsp_url, nullptr, nullptr);
    if (error < 0) {
        std::cerr << "Could not open RTSP input '" << rtsp_url
                  << "': " << ffmpeg_error(error) << '\n';
        cleanup();
        return 1;
    }

    error = avformat_find_stream_info(format_context, nullptr);
    if (error < 0) {
        std::cerr << "Could not find RTSP stream information: "
                  << ffmpeg_error(error) << '\n';
        cleanup();
        return 1;
    }

    av_dump_format(format_context, 0, rtsp_url, 0);
    std::cout << "Input: " << rtsp_url << '\n'
              << "Streams: " << format_context->nb_streams << '\n';

    for (unsigned int stream_index = 0;
         stream_index < format_context->nb_streams; ++stream_index) {
        const auto* stream           = format_context->streams[stream_index];
        const auto* codec_parameters = stream->codecpar;
        const auto* media_type =
            av_get_media_type_string(codec_parameters->codec_type);

        std::cout << "Stream " << stream->index << ": "
                  << (media_type != nullptr ? media_type : "unknown")
                  << ", codec=" << avcodec_get_name(codec_parameters->codec_id);
        if (codec_parameters->codec_type == AVMEDIA_TYPE_VIDEO) {
            std::cout << ", size=" << codec_parameters->width << 'x'
                      << codec_parameters->height;
        }
        std::cout << '\n';
    }

    cleanup();
    return 0;
}
