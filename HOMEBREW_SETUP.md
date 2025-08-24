# 🍺 Homebrew Setup Guide for AirPrint Bridge

## The Problem

The GitHub issue [#25](https://github.com/sapireli/AirPrint_Bridge/issues/25) reports that the Homebrew tap `sapireli/airprint-bridge` doesn't exist, causing this error:

```bash
➜ brew tap sapireli/airprint-bridge
==> Tapping sapireli/airprint-bridge
Cloning into '/usr/local/Homebrew/Library/Taps/sapireli/homebrew-airprint-bridge'...
remote: repository 'https://github.com/sapireli/homebrew-airprint-bridge/' not found.
```

## The Simple Solution

**Yes! You can tap directly from this repository!** Homebrew allows you to tap from any repository that contains a `Formula` directory with Homebrew formulas.

## The Solution

The issue is that the Homebrew tap repository `homebrew-airprint-bridge` doesn't exist in the `sapireli` organization. However, we can fix this much more simply by tapping directly from this repository!

## Option 1: Direct Tap from This Repository (Recommended)

The simplest solution is to tap directly from this repository:

```bash
# Tap directly from the main repository
brew tap sapireli/AirPrint_Bridge

# Install
brew install airprint-bridge
```

This works because Homebrew can tap from any repository that contains Homebrew formulas in a `Formula` directory.

## Option 2: Quick Local Setup (For Testing)

If you want to test the Homebrew installation locally:

## Option 2: Proper Repository Setup (Alternative)

If you prefer to create a separate tap repository (not recommended for this case):

### Step 1: Create the Homebrew Tap Repository

1. Go to [GitHub](https://github.com) and navigate to the `sapireli` organization
2. Create a new repository named `homebrew-airprint-bridge`
3. Make it public
4. Clone it locally:

```bash
git clone https://github.com/sapireli/homebrew-airprint-bridge.git
cd homebrew-airprint-bridge
```

### Step 2: Add the Formula Files

Copy the formula files from this repository:

```bash
# Copy the formula
cp ../AirPrint_Bridge/Formula/airprint-bridge.rb .

# Copy the README
cp ../AirPrint_Bridge/homebrew-airprint-bridge/README.md .
```

### Step 3: Commit and Push

```bash
git add .
git commit -m "Add AirPrint Bridge formula"
git push origin main
```

### Step 4: Test the Installation

Now users can install via Homebrew:

```bash
brew tap sapireli/homebrew-airprint-bridge
brew install airprint-bridge
```

## Option 3: Manual Installation (Fallback)

If you don't want to set up the Homebrew tap, users can still install manually:

```bash
# Clone the repository
git clone https://github.com/sapireli/AirPrint_Bridge.git
cd AirPrint_Bridge

# Make executable and install
chmod +x airprint_bridge.sh
sudo ./airprint_bridge.sh -i
```

## Formula Details

The Homebrew formula (`airprint-bridge.rb`) includes:

- **Description**: Clear explanation of what the tool does
- **Homepage**: Link to the main project
- **URL**: Points to the main repository tarball
- **Version**: Matches the script version (1.3.2)
- **Dependencies**: Requires macOS
- **Installation**: Copies the script to `/usr/local/bin` as `airprint-bridge`
- **Caveats**: Provides usage instructions after installation
- **Test**: Verifies the script runs and shows usage

## Updating the Formula

When updating the main AirPrint Bridge project:

1. Update the version number in `airprint-bridge.rb`
2. Update the SHA256 hash (run `shasum -a 256` on the downloaded tarball)
3. Commit and push the changes to the tap repository

## Verification

After setup, verify the installation works:

```bash
# Check if the tap is available
brew tap --list | grep sapireli/airprint-bridge

# Install the package
brew install airprint-bridge

# Test the installation
sudo airprint-bridge -t
```

## Troubleshooting

### Common Issues

1. **Repository not found**: Ensure the `homebrew-airprint-bridge` repository exists in the `sapireli` organization
2. **Permission denied**: Make sure you have write access to the organization
3. **Formula not found**: Verify the formula file is in the correct location in the tap repository

### Getting Help

- Check the [Homebrew documentation](https://docs.brew.sh/Taps)
- Review the [Homebrew formula cookbook](https://docs.brew.sh/Formula-Cookbook)
- Open an issue in the main [AirPrint Bridge repository](https://github.com/sapireli/AirPrint_Bridge)

## Summary

The Homebrew issue occurs because the tap repository doesn't exist. The **simplest solution** involves:

1. Adding a `Formula` directory to this repository with `airprint-bridge.rb`
2. Pushing the changes to GitHub
3. Users can then tap directly using `brew tap sapireli/AirPrint_Bridge`

This approach eliminates the need for a separate tap repository and provides users with a convenient way to install AirPrint Bridge via Homebrew directly from the main project repository.

**Why this works:** Homebrew can tap from any repository that contains a `Formula` directory with Homebrew formulas, making this the most straightforward solution.
