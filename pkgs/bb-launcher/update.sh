#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update curl jq

set -euo pipefail

OWNER="rainmakerv3"
REPO="BB_Launcher"

LATEST_TAG=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest" | jq -r '.tag_name')
VERSION=$(echo "$LATEST_TAG" | sed 's/^Release//')

if [ -z "$VERSION" ]; then
  echo "ERROR: Could not determine version from tag: $LATEST_TAG"
  exit 1
fi

echo "Latest release: $LATEST_TAG (version: $VERSION)"

nix-update --version "$VERSION" bb-launcher
