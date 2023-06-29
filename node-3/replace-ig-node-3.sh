#!/bin/bash

operating_system=${1:-linux}
other_params=${*:2}

if [ -n "$other_params" ]; then
    echo "Incorrect parameter(s): $other_params. Usage: replace-ig-node-3.sh [linux|macos|windows]"
    exit 0
fi

case ${operating_system} in
linux)
  echo "Running with the Linux CLI binary"
  ./instant-linux package remove --profile=node-3-remove-fhir
  ./instant-linux package init --profile=node-3-deploy-ig
  exit 0
  ;;
macos)
  echo "Running with the MacOS CLI binary"
  ./instant-macos package remove --profile=node-3-remove-fhir
  ./instant-macos package init --profile=node-3-deploy-ig
  exit 0
  ;;
windows)
  echo "Running with the Windows CLI binary"
  ./instant.exe package remove --profile=node-3-remove-fhir
  ./instant.exe package init --profile=node-3-deploy-ig
  exit 0
  ;;
--help)
  echo "Usage: replace-ig-node-3.sh [linux|macos|windows]"
  exit 0
  ;;
*)
  echo "Usage: replace-ig-node-3.sh [linux|macos|windows]"
  exit 0
  ;;
esac
