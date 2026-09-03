#include <StreamingToolBox/StreamingToolBox.hpp>

#include <gtest/gtest.h>

TEST(StreamingToolBox, ReportsAvformatVersion)
{ EXPECT_GT(hw::stb::ffmpeg_avformat_version(), 0U); }
