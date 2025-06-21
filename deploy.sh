#!/bin/bash

# AirPrint Bridge Documentation Deployment Script

echo "🚀 Deploying AirPrint Bridge Documentation to GitHub Pages..."

# Check if we're in the right directory
if [ ! -f "docusaurus.config.ts" ]; then
    echo "❌ Error: Please run this script from the AirPrint_Bridge root directory"
    exit 1
fi

# Build the site
echo "📦 Building the documentation site..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

# Check if gh-pages branch exists
if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
    echo "🔄 Updating existing gh-pages branch..."
else
    echo "🆕 Creating new gh-pages branch..."
fi

# Deploy to GitHub Pages using gh-pages branch
echo "🌐 Deploying to GitHub Pages via gh-pages branch..."
npm run deploy:gh-pages

if [ $? -eq 0 ]; then
    echo "✅ Deployment completed successfully!"
    echo "🌍 Your site should be available at: https://sapireli.github.io/AirPrint_Bridge/"
    echo "⏰ It may take a few minutes for changes to appear."
    echo "📝 The GitHub Actions workflow will automatically deploy from the gh-pages branch."
else
    echo "❌ Deployment failed!"
    exit 1
fi 