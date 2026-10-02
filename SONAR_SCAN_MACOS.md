# Running a SonarCloud scan locally on macOS

Two helper scripts for getting a CMake configure and `sonar-scanner` run working on
this machine.

## `fix_macos_sdk_and_configure.sh`

Regenerates the CMake build tree used for Sonar's C/C++ (CFamily) analysis.

Works around two local issues:

- **SDK/linker mismatch**: `xcrun`'s default SDK resolution picks `MacOSX27.0.sdk`,
  but the installed CommandLineTools linker is from the 26.6.0 package and can't
  parse that SDK's newer `.tbd` architecture tags (`ld: tapi error: malformed file
  ... unknown architecture arm64e.x1-macos`). The script pins `SDKROOT` to the
  matching `MacOSX26.5.sdk`.
- **Missing compile commands**: `CMAKE_EXPORT_COMPILE_COMMANDS=ON` must be passed
  explicitly. Without it, `compile_commands.json` is still produced (FetchContent
  dependencies like flatbuffers turn the flag on for their own sub-build), but it
  contains zero real `onnxruntime/*` compile units — the CFamily sensor then fails
  with "0 C/C++ files analyzed".

```bash
./fix_macos_sdk_and_configure.sh
```

Defaults to `--config Release --update --build_dir build/sonar --cmake_extra_defines
CMAKE_EXPORT_COMPILE_COMMANDS=ON`. Any arguments passed override the defaults and
are forwarded to `build.sh`.

Re-run this whenever CMake configuration changes (new source files, new flags) —
see the `/ort-build` skill for when `--update` is needed.

## `run_sonar_scan.sh`

Runs `sonar-scanner` against SonarCloud.

```bash
./run_sonar_scan.sh <sonarcloud-token>
```

Notes:

- SonarCloud requires `sonar.host.url=https://sonarcloud.io` plus
  `sonar.organization` (both already set in `sonar-project.properties`).
- Pass the token as an argument rather than relying on `$SONAR_TOKEN` — on this
  machine `~/.zshrc` hardcodes a SonarQube Server token that 403s against
  SonarCloud. Generate a SonarCloud token at sonarcloud.io → My Account → Security.
- Relies on `sonar.cfamily.compile-commands` pointing at
  `build/sonar/Release/compile_commands.json`, so run
  `fix_macos_sdk_and_configure.sh` first.

A full scan (fresh submodule sync, CMake configure, ~600 C/C++ compilation units,
SCA dependency resolution across ~80 manifests) takes on the order of 45-50 minutes.
