#!/bin/sh
# Works around a broken default SDK resolution on this machine: `xcrun` picks
# MacOSX27.0.sdk, but the installed CommandLineTools linker is from the 26.6.0
# package and can't parse that SDK's newer .tbd architecture tags
# ("ld: tapi error: malformed file ... unknown architecture arm64e.x1-macos").
# Pinning SDKROOT to the matching 26.5 SDK avoids the mismatch.
#
# CMAKE_EXPORT_COMPILE_COMMANDS=ON is required for the SonarCloud CFamily
# sensor (sonar-scanner) to see any onnxruntime/* source files. Without it,
# compile_commands.json is still produced (FetchContent deps like flatbuffers
# turn it on for their own sub-build) but contains zero real onnxruntime
# compile units, and the CFamily sensor fails with "0 C/C++ files analyzed".
#
# Usage: ./fix_macos_sdk_and_configure.sh [build.sh args...]
# Defaults to: --config Release --update --build_dir build/sonar
#              --cmake_extra_defines CMAKE_EXPORT_COMPILE_COMMANDS=ON

set -e

export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk

if [ "$#" -eq 0 ]; then
  set -- --config Release --update --build_dir build/sonar \
    --cmake_extra_defines CMAKE_EXPORT_COMPILE_COMMANDS=ON
fi

exec ./build.sh "$@"
