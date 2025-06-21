# Homebrew Tap Setup Guide

This guide will help you set up a Homebrew tap for the AirPrint Bridge project.

## Step 1: Create a New Repository for the Tap

1. Go to GitHub and create a new repository named `homebrew-airprint-bridge`
2. The repository name must follow the pattern: `homebrew-<formula-name>`
3. Make it public (Homebrew taps must be public)
4. Don't initialize with README, .gitignore, or license (we'll add these files)

## Step 2: Clone and Set Up the Tap Repository

```bash
# Clone your new tap repository
git clone https://github.com/sapireli/homebrew-airprint-bridge.git
cd homebrew-airprint-bridge

# Copy the formula files from this directory
cp -r ../AirPrint_Bridge/Formula/* .

# Make the script executable
chmod +x calculate-sha256.sh

# Initialize git and push
git add .
git commit -m "Initial commit: Add AirPrint Bridge formula"
git push origin main
```

## Step 3: Test the Formula Locally

Before publishing, test your formula:

```bash
# Test the formula syntax
brew audit --strict --online Formula/airprint-bridge.rb

# Test the formula installation (in a test environment)
brew install --build-from-source Formula/airprint-bridge.rb
```

## Step 4: Create a Release Tag

In your main AirPrint Bridge repository:

```bash
# Create and push a new tag
git tag v1.0.0
git push origin v1.0.0
```

## Step 5: Calculate SHA256 and Update Formula

```bash
# Calculate the SHA256 for the new release
./calculate-sha256.sh 1.0.0

# Update the formula with the new SHA256
# Edit Formula/airprint-bridge.rb and replace PLACEHOLDER_SHA256 with the actual hash
```

## Step 6: Update and Publish the Tap

```bash
# Update the formula with the new version and SHA256
git add Formula/airprint-bridge.rb
git commit -m "Update to version 1.0.0"
git push origin main
```

## Step 7: Test the Installation

Now users can install your formula:

```bash
# Add the tap
brew tap sapireli/airprint-bridge

# Install the formula
brew install airprint-bridge

# Test the installation
airprint-bridge --help
```

## Maintaining the Tap

### For New Releases

1. **Create a new tag** in the main repository:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

2. **Update the formula** in the tap repository:
   ```bash
   # Calculate new SHA256
   ./calculate-sha256.sh 1.1.0
   
   # Update the formula file
   # Change the version and SHA256 in Formula/airprint-bridge.rb
   ```

3. **Commit and push** the changes:
   ```bash
   git add Formula/airprint-bridge.rb
   git commit -m "Update to version 1.1.0"
   git push origin main
   ```

### Formula Validation

Regularly validate your formula:

```bash
# Check formula syntax
brew audit --strict --online Formula/airprint-bridge.rb

# Test installation
brew install --build-from-source Formula/airprint-bridge.rb

# Test uninstallation
brew uninstall airprint-bridge
```

## Troubleshooting

### Common Issues

1. **SHA256 mismatch**: Make sure you're using the correct SHA256 for the release
2. **URL not found**: Ensure the GitHub release exists and is public
3. **Installation fails**: Check that all dependencies are met

### Formula Best Practices

1. **Version URLs**: Use specific version tags, not `main` branch
2. **Dependencies**: Only include necessary dependencies
3. **Caveats**: Provide helpful post-installation instructions
4. **Tests**: Include meaningful tests in the formula

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Tap Documentation](https://docs.brew.sh/Taps)
- [Homebrew Audit Documentation](https://docs.brew.sh/Manpage#audit-options-formula-cask-) 