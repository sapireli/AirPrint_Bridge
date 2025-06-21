#!/bin/bash

# Script to calculate SHA256 hash for Homebrew formula
# Usage: ./calculate-sha256.sh <version>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

VERSION=$1
URL="https://github.com/sapireli/AirPrint_Bridge/archive/refs/tags/v${VERSION}.tar.gz"

echo "Calculating SHA256 for version ${VERSION}..."
echo "URL: ${URL}"
echo ""

# Download the file and calculate SHA256
SHA256=$(curl -sL "${URL}" | shasum -a 256 | cut -d' ' -f1)

echo "SHA256: ${SHA256}"
echo ""
echo "Update your Formula/airprint-bridge.rb file with:"
echo "sha256 \"${SHA256}\"" 