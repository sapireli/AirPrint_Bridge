---
sidebar_position: 5
---

# 🤝 Contributing

We welcome contributions to AirPrint Bridge! Whether you're reporting bugs, suggesting features, or contributing code, your help is appreciated.

## How to Contribute

### 🐛 Reporting Bugs

Before reporting a bug, please:

1. **Check existing issues** to see if it's already been reported
2. **Search the documentation** for solutions
3. **Try the troubleshooting guide** first

When reporting a bug, please include:

- **macOS version** (e.g., macOS 14.2.1)
- **AirPrint Bridge version** (if known)
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Error messages** or logs
- **System information** (relevant hardware/network details)

**Bug report template:**
```markdown
## Bug Description
Brief description of the issue

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## System Information
- macOS Version: 
- AirPrint Bridge Version:
- Printer Model:
- Network Setup:

## Error Messages/Logs
Paste any error messages or relevant logs here
```

### 💡 Suggesting Features

We welcome feature suggestions! When suggesting a feature:

- **Explain the problem** you're trying to solve
- **Describe your proposed solution**
- **Consider the impact** on existing users
- **Check if it aligns** with the project's goals

### 🔧 Contributing Code

#### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/AirPrint_Bridge.git
   cd AirPrint_Bridge
   ```

3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes** and test thoroughly

5. **Commit your changes** with clear commit messages:
   ```bash
   git commit -m "Add feature: brief description"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a pull request** with a detailed description

#### Code Style Guidelines

- **Follow existing code style** and conventions
- **Add comments** for complex logic
- **Test your changes** thoroughly
- **Update documentation** if needed
- **Keep commits focused** and atomic

#### Testing Your Changes

Before submitting a pull request:

1. **Test on multiple macOS versions** if possible
2. **Test with different printer types**
3. **Verify installation and uninstallation** work correctly
4. **Check that logging** works as expected
5. **Test network scenarios** (Wi-Fi, Ethernet, different networks)

### 📚 Contributing Documentation

Documentation improvements are highly valued! You can help by:

- **Fixing typos** or unclear language
- **Adding examples** or use cases
- **Improving troubleshooting guides**
- **Translating documentation** to other languages
- **Adding screenshots** or diagrams

### 🧪 Testing

Help us test AirPrint Bridge by:

- **Testing on different macOS versions**
- **Testing with various printer models**
- **Testing network configurations**
- **Reporting compatibility issues**
- **Providing feedback** on new features

## Development Environment

### Prerequisites

- macOS 10.15 or later
- Git
- Text editor (VS Code, Sublime Text, etc.)
- Terminal access

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sapireli/AirPrint_Bridge.git
   cd AirPrint_Bridge
   ```

2. **Make the script executable**:
   ```bash
   chmod +x airprint_bridge.sh
   ```

3. **Test your changes**:
   ```bash
   sudo ./airprint_bridge.sh -t
   ```

### Testing Checklist

Before submitting changes, ensure:

- [ ] Script runs without errors
- [ ] Installation works correctly
- [ ] Uninstallation works correctly
- [ ] Logging functions properly
- [ ] Documentation is updated
- [ ] No sensitive information is exposed

## Pull Request Guidelines

### Before Submitting

1. **Test thoroughly** on your system
2. **Update documentation** if needed
3. **Follow the commit message format**
4. **Keep changes focused** and small
5. **Add tests** if applicable

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Other (please describe)

## Testing
- [ ] Tested on macOS [version]
- [ ] Tested with [printer model]
- [ ] Installation works
- [ ] Uninstallation works
- [ ] Logging works correctly

## Checklist
- [ ] Code follows existing style
- [ ] Documentation updated
- [ ] No sensitive data exposed
- [ ] Commit messages are clear
```

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please:

- **Be respectful** and considerate
- **Use inclusive language**
- **Focus on constructive feedback**
- **Help others learn** and grow

## Recognition

Contributors will be recognized in:

- **GitHub contributors list**
- **Release notes**
- **Documentation acknowledgments**
- **Project README** (for significant contributions)

## Questions?

If you have questions about contributing:

- **Check the documentation** first
- **Search existing issues** and discussions
- **Start a discussion** on GitHub
- **Ask in issues** with the "question" label

## Thank You!

Thank you for considering contributing to AirPrint Bridge! Every contribution, no matter how small, helps make the project better for everyone.

---

**Ready to contribute?** Start by [forking the repository](https://github.com/sapireli/AirPrint_Bridge/fork) or [opening an issue](https://github.com/sapireli/AirPrint_Bridge/issues/new). 