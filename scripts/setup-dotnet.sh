#!/usr/bin/env bash

# setup-dotnet.sh — install .NET Lambda tooling. Idempotent.
# Run after `brew bundle` has installed the dotnet SDK.

set -euo pipefail

if ! command -v dotnet >/dev/null 2>&1; then
  echo "dotnet not on PATH. Run 'brew bundle' first." >&2
  exit 1
fi

# Project templates (dotnet new lambda.EmptyFunction, lambda.WebAPI, ...)
dotnet new install Amazon.Lambda.Templates --force

# CLI tool (dotnet lambda deploy-function, package, ...)
if dotnet tool list -g | grep -qi amazon.lambda.tools; then
  dotnet tool update -g Amazon.Lambda.Tools
else
  dotnet tool install -g Amazon.Lambda.Tools
fi
