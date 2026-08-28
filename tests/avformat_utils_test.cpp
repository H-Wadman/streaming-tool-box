#include <avformat_utils.hpp>

#include <cassert>
#include <fstream>
#include <gtest/gtest.h>
#include <utility>

using namespace hw::stb;

TEST(AVFormatUtils, PrintsStreams) {}

TEST(AVFormatUtils, NetworkConstructs)
{
    using namespace hw::stb;
    auto network_opt = Libavformat_network::create();
    ASSERT_TRUE(network_opt.has_value());
}

TEST(AVFormatUtils, NetworkMovesCorrectly)
{
    auto network_opt = Libavformat_network::create();
    ASSERT_TRUE(network_opt.has_value());
    assert(network_opt.has_value());
    auto network{std::move(network_opt.value())};
}

TEST(AVFormatUtils, PrintStream)
{
    auto network_opt = Libavformat_network::create();
    ASSERT_TRUE(network_opt.has_value());

    std::ofstream out{"print_stream_test.txt"};
    ASSERT_TRUE(out.is_open());
    auto av_format =
        open_avformat("https://media.w3.org/2010/05/sintel/trailer.mp4");

    EXPECT_NE(av_format.get(), nullptr);
    print_streams(av_format.get(), out);
}
