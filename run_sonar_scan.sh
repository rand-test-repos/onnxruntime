#!/bin/sh
# Runs sonar-scanner against SonarCloud for this project.
#
# Notes from getting this working:
# - SonarCloud (unlike SonarQube Server) requires sonar.host.url=https://sonarcloud.io
#   plus sonar.organization, both already set in sonar-project.properties.
# - The SONAR_TOKEN in the environment/~/.zshrc on this machine is paired with
#   a local SonarQube Server, not SonarCloud, so it gets a 403 here. Pass a
#   SonarCloud token explicitly (generate one at sonarcloud.io -> My Account ->
#   Security) rather than relying on $SONAR_TOKEN.
# - sonar.cfamily.compile-commands points at build/sonar/Release/compile_commands.json;
#   run ./fix_macos_sdk_and_configure.sh first (or after any CMake config change)
#   so that file has real onnxruntime/* entries, not just dependency sub-builds.
#
# Usage: ./run_sonar_scan.sh <sonarcloud-token>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <sonarcloud-token>" >&2
  exit 1
fi

exec sonar-scanner -Dsonar.host.url=https://sonarcloud.io -Dsonar.token="$1"
