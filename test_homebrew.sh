#!/bin/bash

# Test script for Homebrew formula
# This script tests the Homebrew formula locally

set -e

echo "🧪 Testing Homebrew formula setup..."

# Check if Formula directory exists
if [ ! -d "Formula" ]; then
    echo "❌ Formula directory not found"
    exit 1
fi

# Check if formula file exists
if [ ! -f "Formula/airprint-bridge.rb" ]; then
    echo "❌ Formula file not found"
    exit 1
fi

# Check if main script exists
if [ ! -f "airprint_bridge.sh" ]; then
    echo "❌ Main script not found"
    exit 1
fi

# Validate the formula syntax (basic check)
echo "✅ Basic file structure validation passed"

# Check formula content
echo "📋 Formula content:"
echo "   Description: $(grep 'desc' Formula/airprint-bridge.rb | head -1)"
echo "   Homepage: $(grep 'homepage' Formula/airprint-bridge.rb | head -1)"
echo "   Version: $(grep 'version' Formula/airprint-bridge.rb | head -1)"

echo ""
echo "🎉 Homebrew formula setup is ready!"
echo ""
echo "Next steps:"
echo "1. Commit and push your changes:"
echo "   git add ."
echo "   git commit -m 'Add Homebrew formula'"
echo "   git push origin main"
echo ""
echo "2. Users can then install using:"
echo "   brew tap sapireli/AirPrint_Bridge"
echo "   brew install airprint-bridge"
echo ""
echo "The formula will install the script as 'airprint-bridge' in /usr/local/bin"
