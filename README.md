# StreamingToolBox

StreamingToolBox is a C++20 library scaffold for media streaming workflows. The project targets Unix-like platforms and uses CMake targets throughout so it can be built directly or consumed through an installed package.

## Requirements

- CMake 3.31 or newer
- A C++20-capable compiler
- Ninja for the included presets
- FFmpeg development packages for `libavcodec`, `libavformat`, `libavutil`, `libswscale`, and `libswresample`
- `pkg-config` is recommended for FFmpeg discovery

GoogleTest is only required when `BUILD_TESTING=ON`. CMake first searches for a system GTest package. For top-level builds it can download a pinned GoogleTest commit with FetchContent; disable that behavior with `-DSTREAMINGTOOLBOX_ALLOW_GTEST_DOWNLOAD=OFF`.

## Configure and build

```sh
cmake --preset unix-debug
cmake --build --preset unix-debug
ctest --preset unix-debug
```

The release workflow uses the corresponding `unix-release` presets.

## clang-tidy

The `unix-debug-clang-tidy` preset enables clang-tidy for project-owned targets:

```sh
cmake --preset unix-debug-clang-tidy
cmake --build --preset unix-debug-clang-tidy
```

Place the project's `.clang-tidy` configuration in the source tree. CMake does not generate or override that file. Set `STREAMINGTOOLBOX_CLANG_TIDY_EXECUTABLE` when clang-tidy is not on `PATH`.

## Sanitizers

Sanitizers are opt-in and target-scoped. The ASan and UBSan combination is available through a preset:

```sh
cmake --preset unix-debug-asan-ubsan
cmake --build --preset unix-debug-asan-ubsan
ctest --preset unix-debug-asan-ubsan
```

ThreadSanitizer has its own preset:

```sh
cmake --preset unix-debug-tsan
cmake --build --preset unix-debug-tsan
ctest --preset unix-debug-tsan
```

For other combinations, use these cache options:

```text
STREAMINGTOOLBOX_ENABLE_ASAN
STREAMINGTOOLBOX_ENABLE_UBSAN
STREAMINGTOOLBOX_ENABLE_TSAN
STREAMINGTOOLBOX_ENABLE_MSAN
STREAMINGTOOLBOX_ENABLE_LSAN
```

MemorySanitizer requires the upstream Clang compiler on Linux and instrumented dependencies. Standalone LeakSanitizer is supported on Linux. ThreadSanitizer, MemorySanitizer, and LeakSanitizer cannot be combined with AddressSanitizer; incompatible combinations are rejected during configuration. Sanitizer runtimes also depend on host kernel and runtime support.

## Install and consume

```sh
cmake --preset unix-release
cmake --build --preset unix-release
cmake --install build/unix-release --prefix "$PWD/build/install"
```

An installed consumer can use the exported target:

```cmake
find_package(StreamingToolBox CONFIG REQUIRED)
target_link_libraries(app PRIVATE StreamingToolBox::StreamingToolBox)
```

Set `CMAKE_PREFIX_PATH` to the installation prefix when configuring the consumer. The package rediscovers its required FFmpeg components through the installed `FindFFmpeg.cmake` module.