# AirPrint Bridge Documentation

This is the documentation site for [AirPrint Bridge](https://github.com/sapireli/AirPrint_Bridge), built with [Docusaurus](https://docusaurus.io/).

## 🖨️ About AirPrint Bridge

AirPrint Bridge enables AirPrint functionality on macOS for printers that don't natively support it. This script allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint.

## 📚 Documentation Features

- **Comprehensive Guides**: Step-by-step installation and configuration instructions
- **Troubleshooting**: Common issues and solutions
- **API Reference**: Detailed technical documentation
- **Examples**: Real-world use cases and code samples
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile devices

## 🚀 Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) version 18.0 or above
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sapireli/AirPrint_Bridge.git
   cd AirPrint_Bridge/airprint-bridge-docs
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Start the development server**:
   ```bash
   npm start
   ```

4. **Open your browser** and navigate to `http://localhost:3000`

## 🛠️ Development

### Available Scripts

- `npm start` - Start the development server
- `npm run build` - Build the website for production
- `npm run serve` - Serve the built website locally
- `npm run clear` - Clear the Docusaurus cache
- `npm run typecheck` - Run TypeScript type checking

### Project Structure

```
airprint-bridge-docs/
├── docs/                    # Documentation pages
│   ├── intro.md            # Homepage content
│   ├── installation.md     # Installation guide
│   ├── troubleshooting.md  # Troubleshooting guide
│   ├── license.md          # License information
│   └── contributing.md     # Contributing guide
├── src/
│   ├── css/                # Custom styles
│   └── pages/              # Additional pages
├── static/                 # Static assets
│   └── img/                # Images and logos
├── docusaurus.config.ts    # Docusaurus configuration
├── sidebars.ts            # Documentation sidebar
└── package.json           # Dependencies and scripts
```

### Adding New Documentation

1. **Create a new markdown file** in the `docs/` directory
2. **Add frontmatter** with metadata:
   ```markdown
   ---
   sidebar_position: 6
   title: Your Page Title
   ---
   ```
3. **Update the sidebar** in `sidebars.ts` if needed
4. **Test your changes** with `npm start`

### Styling

Custom styles are defined in `src/css/custom.css`. The site uses:
- **Primary Color**: `#007AFF` (Apple Blue)
- **Secondary Color**: `#FF6B35` (Orange accent)
- **Typography**: System fonts for optimal readability

## 🌐 Deployment

### GitHub Pages (Automatic)

The site is automatically deployed to GitHub Pages when changes are pushed to the main branch. The deployment is handled by GitHub Actions in `.github/workflows/deploy.yml`.

### Manual Deployment

To deploy manually:

```bash
npm run build
npm run deploy
```

### Environment Variables

For deployment, you may need to set:
- `GIT_USER` - Your GitHub username
- `USE_SSH` - Set to `true` for SSH deployment

## 📝 Content Guidelines

### Writing Style

- **Clear and concise**: Use simple, direct language
- **Step-by-step**: Break complex processes into numbered steps
- **Code examples**: Include practical, working code samples
- **Screenshots**: Add visual aids when helpful

### Markdown Features

- **Code blocks**: Use syntax highlighting for code
- **Admonitions**: Use callouts for important information
- **Links**: Link to relevant external resources
- **Images**: Optimize images for web use

### Code Examples

```bash
# Installation command
sudo ./airprint_bridge.sh -i

# Test mode
sudo ./airprint_bridge.sh -t
```

## 🔧 Configuration

### Docusaurus Configuration

The main configuration is in `docusaurus.config.ts`:
- **Site metadata**: Title, description, URLs
- **Navigation**: Menu items and links
- **Theme**: Colors, fonts, and styling
- **Plugins**: Additional functionality

### Sidebar Configuration

Documentation structure is defined in `sidebars.ts`:
- **Auto-generation**: Automatically creates sidebar from file structure
- **Manual configuration**: Custom sidebar structure when needed

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**: Change the port with `npm start -- --port 3001`
2. **Build errors**: Clear cache with `npm run clear`
3. **Type errors**: Run `npm run typecheck` to identify issues

### Getting Help

- **Documentation**: Check the [Docusaurus docs](https://docusaurus.io/docs)
- **Issues**: Report problems on [GitHub](https://github.com/sapireli/AirPrint_Bridge/issues)
- **Discussions**: Join conversations on [GitHub Discussions](https://github.com/sapireli/AirPrint_Bridge/discussions)

## 🤝 Contributing

We welcome contributions to the documentation! Please see our [Contributing Guide](docs/contributing.md) for details.

### Documentation Contributions

- **Fix typos** and improve clarity
- **Add examples** and use cases
- **Update screenshots** for new macOS versions
- **Translate content** to other languages
- **Improve structure** and navigation

## 📄 License

This documentation is licensed under the MIT License - see the [License](docs/license.md) page for details.

## 🙏 Acknowledgments

- **Docusaurus Team** for the excellent documentation framework
- **AirPrint Bridge Contributors** for their valuable feedback
- **Community Members** for testing and suggestions

---

**Need help?** Check out our [Installation Guide](docs/installation.md) or [Troubleshooting Guide](docs/troubleshooting.md).
