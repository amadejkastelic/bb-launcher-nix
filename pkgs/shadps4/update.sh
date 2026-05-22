#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update curl jq

set -euo pipefail

OWNER="shadps4-emu"
REPO="shadPS4"

LATEST_TAG=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest" | jq -r '.tag_name')
VERSION=$(echo "$LATEST_TAG" | sed 's/^v\.//')

if [ -z "$VERSION" ]; then
  echo "ERROR: Could not determine version from tag: $LATEST_TAG"
  exit 1
fi

echo "Latest release: $LATEST_TAG (version: $VERSION)"

nix-update --flake --version "$VERSION" shadps4
