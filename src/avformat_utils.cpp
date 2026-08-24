#include "avformat_utils.hpp"

#include <array>
#include <iostream>
#include <optional>
#include <string>

extern "C"
{
#include <libavformat/avformat.h>
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
} //namespace

namespace hw::stb
{
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
    if (m_active) { avformat_network_deinit(); }

    m_active       = other.m_active;
    other.m_active = false;

    return *this;
}

Libavformat_network::~Libavformat_network()
{
    if (m_active) { avformat_network_deinit(); }
}

Libavformat_network::Libavformat_network(bool active) : m_active{active} {};
} //namespace hw::stb
