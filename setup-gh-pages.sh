#!/bin/bash

# Setup gh-pages branch for AirPrint Bridge Documentation

echo "🔧 Setting up gh-pages branch for AirPrint Bridge Documentation..."

# Check if we're in the right directory
if [ ! -f "docusaurus.config.ts" ]; then
    echo "❌ Error: Please run this script from the AirPrint_Bridge root directory"
    exit 1
fi

# Check if gh-pages branch already exists
if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
    echo "✅ gh-pages branch already exists!"
    echo "You can now use ./deploy.sh to deploy your documentation."
    exit 0
fi

# Build the site first
echo "📦 Building the documentation site..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

# Create and push gh-pages branch
echo "🆕 Creating gh-pages branch..."
git checkout --orphan gh-pages
git rm -rf .
git add build/
git mv build/* .
git rmdir build
git commit -m "Initial gh-pages deployment"

echo "🚀 Pushing gh-pages branch to origin..."
git push origin gh-pages

# Switch back to main branch
git checkout main

echo "✅ gh-pages branch setup completed!"
echo "🌍 Your site should be available at: https://sapireli.github.io/AirPrint_Bridge/"
echo "⏰ It may take a few minutes for the initial deployment to complete."
echo ""
echo "For future deployments, simply run: ./deploy.sh" 