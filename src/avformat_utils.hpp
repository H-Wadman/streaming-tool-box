#pragma once

#include <iostream>
#include <memory>
#include <optional>

extern "C"
{
#include <libavformat/avformat.h>
#include <libavutil/dict.h>
}

namespace hw::stb
{


class Libavformat_network
{
 public:
    static auto create() -> std::optional<Libavformat_network>;

    //Copy constructors
    auto operator=(Libavformat_network const&) -> Libavformat_network = delete;
    Libavformat_network(Libavformat_network const&)                   = delete;

    //Move constructors
    Libavformat_network(Libavformat_network&& other) noexcept;
    auto operator=(Libavformat_network&& other) noexcept
        -> Libavformat_network&;

    //Destructor
    ~Libavformat_network();

 private:
    bool m_active{false};

    explicit Libavformat_network(bool active);
};

struct AVFormatContext_closer
{
    auto operator()(AVFormatContext* ptr) { avformat_close_input(&ptr); }
};

using AVFormatContext_ptr =
    std::unique_ptr<AVFormatContext, AVFormatContext_closer>;

auto open_avformat(std::string const& url)
    -> std::unique_ptr<AVFormatContext, AVFormatContext_closer>;

void print_stream(AVStream const* const stream, std::ostream& out);

auto rtsp_stream_connect(std::string const& rtsp_url)
    -> std::unique_ptr<AVFormatContext, AVFormatContext_closer>;

struct Credentials
{
    std::string username;
    std::string password;
};

auto rtsp_stream_connect(std::string const& rtsp_url,
                         Credentials const& credentials) -> AVFormatContext_ptr;

/*!
 * \brief Prints info about the streams in format_context to the specified
 * out channel
 */
void print_streams(AVFormatContext* format_context, std::ostream& out);

} //namespace hw::stb
