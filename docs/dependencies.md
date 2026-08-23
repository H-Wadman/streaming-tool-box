# Dependencies

## FFmpeg

FFmpeg is required by the library. The project discovers these components by default:

- `libavcodec`
- `libavformat`
- `libavutil`
- `libswscale`
- `libswresample`

The project-local `FindFFmpeg.cmake` prefers `pkg-config` metadata and falls back to conventional CMake header and library searches. It provides `FFmpeg::avcodec`, `FFmpeg::avformat`, `FFmpeg::avutil`, `FFmpeg::swscale`, `FFmpeg::swresample`, and the aggregate `FFmpeg::FFmpeg` target. Optional components `avfilter`, `avdevice`, and `postproc` are also supported when requested by a caller.

On Debian or Ubuntu, the development packages are typically installed with:

```sh
sudo apt install pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev
```

If FFmpeg is installed in a non-standard prefix, set `CMAKE_PREFIX_PATH` or configure `PKG_CONFIG_PATH` before running CMake.

## GoogleTest

GoogleTest is a development-only dependency. With `BUILD_TESTING=ON`, CMake searches for an installed package first. If no usable `GTest::gtest_main` target is found and `STREAMINGTOOLBOX_ALLOW_GTEST_DOWNLOAD=ON`, FetchContent retrieves the pinned commit configured by `STREAMINGTOOLBOX_GTEST_GIT_TAG`.

For an offline build, install GTest and set:

```sh
cmake -S . -B build -DBUILD_TESTING=ON -DSTREAMINGTOOLBOX_ALLOW_GTEST_DOWNLOAD=OFF
```

## Static and shared builds

`BUILD_SHARED_LIBS` controls the library type. FFmpeg remains a private implementation dependency, while CMake preserves the required link relationship for static-library consumers through the exported target metadata.