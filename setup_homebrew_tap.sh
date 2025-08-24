#!/bin/bash

# Setup script for AirPrint Bridge Homebrew tap
# This script helps set up the Homebrew tap directly from this repository

set -e

echo "🚀 Setting up AirPrint Bridge Homebrew tap..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check if Formula directory exists
if [ ! -d "Formula" ]; then
    echo "❌ Formula directory not found. Please ensure the Formula directory exists with airprint-bridge.rb"
    exit 1
fi

# Check if the formula file exists
if [ ! -f "Formula/airprint-bridge.rb" ]; then
    echo "❌ Formula file not found. Please ensure Formula/airprint-bridge.rb exists"
    exit 1
fi

echo "✅ Formula files found. You can now tap directly from this repository!"

echo ""
echo "To install AirPrint Bridge via Homebrew:"
echo ""
echo "1. Push your changes to GitHub:"
echo "   git add ."
echo "   git commit -m 'Add Homebrew formula'"
echo "   git push origin main"
echo ""
echo "2. Then users can install using:"
echo "   brew tap sapireli/AirPrint_Bridge"
echo "   brew install airprint-bridge"
echo ""
echo "3. To test the installation:"
echo "   sudo airprint-bridge -t"
echo ""
echo "4. To install the service:"
echo "   sudo airprint-bridge -i"
echo ""
echo "Note: This approach taps directly from the main repository,"
echo "eliminating the need for a separate tap repository!"
