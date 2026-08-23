#include <StreamingToolBox/StreamingToolBox.hpp>

#include <gtest/gtest.h>

TEST(StreamingToolBox, ReportsAvformatVersion)
{ EXPECT_GT(streaming_toolbox::ffmpeg_avformat_version(), 0U); }