#!/bin/bash

operating_system=${1:-linux}
other_params=${*:2}

if [ -n "$other_params" ]; then
    echo "Incorrect parameter(s): $other_params. Usage: replace-ig-local.sh [linux|macos|windows]"
    exit 0
fi

case ${operating_system} in
linux)
  echo "Running with the Linux CLI binary"
  ./instant-linux package down --profile=local-remove-fhir
  ./instant-linux package up --profile=local-deploy-ig
  exit 0
  ;;
macos)
  echo "Running with the MacOS CLI binary"
  ./instant-macos package down --profile=local-remove-fhir
  ./instant-macos package up --profile=local-deploy-ig
  exit 0
  ;;
windows)
  echo "Running with the Windows CLI binary"
  ./instant.exe package down --profile=local-remove-fhir
  ./instant.exe package up --profile=local-deploy-ig
  exit 0
  ;;
--help)
  echo "Usage: replace-ig-local.sh [linux|macos|windows]"
  exit 0
  ;;
*)
  echo "Usage: replace-ig-local.sh [linux|macos|windows]"
  exit 0
  ;;
esac
