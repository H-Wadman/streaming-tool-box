#pragma once

#include <optional>

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

} //namespace hw::stb
