# Homebrew Integration for AirPrint Bridge

This document outlines the complete setup for making AirPrint Bridge available via Homebrew.

## 📁 Files Created

### Formula Directory
- `Formula/airprint-bridge.rb` - The Homebrew formula
- `Formula/README.md` - Documentation for the Homebrew tap
- `Formula/calculate-sha256.sh` - Helper script for calculating SHA256 hashes
- `Formula/HOMEBREW_SETUP.md` - Detailed setup guide

### GitHub Actions
- `.github/workflows/update-homebrew.yml` - Automated workflow for updating the formula

### Updated Files
- `README.md` - Added Homebrew installation instructions

## 🚀 Quick Setup Steps

### 1. Create the Homebrew Tap Repository

1. Go to GitHub and create a new repository named `homebrew-airprint-bridge`
2. Make it public
3. Don't initialize with any files

### 2. Set Up the Tap Repository

```bash
# Clone your new tap repository
git clone https://github.com/sapireli/homebrew-airprint-bridge.git
cd homebrew-airprint-bridge

# Copy the formula files
cp -r ../AirPrint_Bridge/Formula/* .

# Initialize and push
git add .
git commit -m "Initial commit: Add AirPrint Bridge formula"
git push origin main
```

### 3. Create a GitHub Release

In your main AirPrint Bridge repository:

```bash
# Create and push a tag
git tag v1.0.0
git push origin v1.0.0

# Go to GitHub and create a release from this tag
```

### 4. Update the Formula

```bash
# Calculate SHA256
cd homebrew-airprint-bridge
./calculate-sha256.sh 1.0.0

# Update the formula with the actual SHA256
# Edit Formula/airprint-bridge.rb and replace PLACEHOLDER_SHA256

# Commit and push
git add Formula/airprint-bridge.rb
git commit -m "Update to version 1.0.0"
git push origin main
```

### 5. Set Up GitHub Actions (Optional)

To enable automatic updates:

1. Create a Personal Access Token with repo access
2. Add it as a secret named `HOMEBREW_TAP_TOKEN` in your main repository
3. The workflow will automatically update the formula when you create new releases

## 🧪 Testing the Installation

Once set up, users can install via:

```bash
# Add the tap
brew tap sapireli/airprint-bridge

# Install the formula
brew install airprint-bridge

# Test the installation
airprint-bridge --help
```

## 📋 Formula Details

The formula (`Formula/airprint-bridge.rb`) includes:

- **Dependencies**: macOS requirement
- **Installation**: Copies the script to `/usr/local/bin/airprint-bridge`
- **Documentation**: Installs docs and README
- **Caveats**: Post-installation instructions
- **Tests**: Basic functionality tests

## 🔄 Maintenance

### For New Releases

1. **Create a new tag** in the main repository
2. **Create a GitHub release** from the tag
3. **The GitHub Action will automatically update the formula** (if set up)
4. **Or manually update** using the calculate-sha256.sh script

### Manual Update Process

```bash
# Calculate new SHA256
./calculate-sha256.sh <version>

# Update formula file
# Edit Formula/airprint-bridge.rb with new version and SHA256

# Commit and push
git add Formula/airprint-bridge.rb
git commit -m "Update to version <version>"
git push origin main
```

## 🛠️ Formula Validation

Regularly validate your formula:

```bash
# Check syntax
brew audit --strict --online Formula/airprint-bridge.rb

# Test installation
brew install --build-from-source Formula/airprint-bridge.rb

# Test uninstallation
brew uninstall airprint-bridge
```

## 📚 Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Tap Documentation](https://docs.brew.sh/Taps)
- [Homebrew Audit Documentation](https://docs.brew.sh/Manpage#audit-options-formula-cask-)

## ✅ Checklist

- [ ] Create `homebrew-airprint-bridge` repository
- [ ] Copy formula files to the tap repository
- [ ] Create initial release tag (v1.0.0)
- [ ] Calculate and update SHA256 in formula
- [ ] Test formula installation
- [ ] Set up GitHub Actions (optional)
- [ ] Update main README with Homebrew instructions
- [ ] Test complete installation process

## 🎯 Benefits

Making AirPrint Bridge available via Homebrew provides:

1. **Easy Installation**: One command installation
2. **Automatic Updates**: Users can easily update with `brew upgrade`
3. **Dependency Management**: Homebrew handles dependencies
4. **Wide Distribution**: Available to all Homebrew users
5. **Professional Appearance**: Shows project maturity and ease of use 