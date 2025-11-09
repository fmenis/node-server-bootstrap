# NodeJs Server Bootstrap 🚀

A comprehensive provisioning repository to automate software installation and configuration for Node.js server environments. Say goodbye to repetitive manual setup!

## Overview

This repository provides automated scripts and configurations to quickly bootstrap a Node.js server with all necessary dependencies, tools, and configurations. Perfect for setting up new development environments, CI/CD pipelines, or production servers.

## Features

- ✅ Automated software installation
- ✅ Pre-configured development tools
- ✅ Consistent environment setup across machines
- ✅ Version-controlled configuration files
- ✅ Time-saving automation scripts
- ✅ Easy to customize and extend

## Prerequisites

Before running the provisioning scripts, ensure you have:

- A fresh Linux/Unix-based server or local machine
- Root or sudo access

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/fmenis/node-server-bootstrap.git
   cd node-server-bootstrap
   ```

2. **Make scripts executable**

   ```bash
   chmod +x *.sh
   ```

3. **Run the main provisioning script**

   ```bash
   ./provision.sh
   ```

4. **Follow the on-screen prompts** (if any) to complete the setup

## What Gets Installed

The provisioning process typically includes:

- **Node.js** - Latest LTS version
- **npm** - Package managers
- **Git** - Version control
- **Development tools** - Essential build tools and compilers
- **Common utilities** - curl, wget, vim, etc.
- **Security updates** - Latest system patches

## Configuration

### Customizing the Installation

You can customize what gets installed by editing the provisioning scripts:

```bash
# Modify the main script
nano provision.sh
```

## Project Structure

```
node-server-bootstrap/
├── provision.sh          # Main provisioning script
├── scripts/              # Individual setup scripts
├── templates/            # Configuration templates
└── README.md             # This file
```

## Usage Examples

### Basic Server Setup

```bash
./provision.sh
```

## Testing

Before deploying to production, test the provisioning scripts in a safe environment:

```bash
# Using Docker
docker run -it ubuntu:latest /bin/bash
# Then run your provisioning scripts

# Or use a VM/Vagrant
vagrant up
```

## Troubleshooting

### Common Issues

**Permission denied errors**

```bash
chmod +x provision.sh
sudo ./provision.sh
```

**Package not found**

```bash
sudo apt-get update
# or
sudo yum update
```

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Keep scripts modular and reusable
- Add comments for complex operations
- Test on multiple distributions if possible
- Update documentation for new features

## Supported Operating Systems

- ✅ Ubuntu 20.04+
- ✅ Debian 10+
- ✅ CentOS 7+
- ✅ RHEL 8+
- ⚠️ macOS (partial support)
- ❌ Windows (use WSL2)

## Roadmap

- [ ] Add configuration templates
- [ ] Create interactive setup wizard
- [ ] Add rollback functionality

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Filippo Menis** ([@fmenis](https://github.com/fmenis))

## Acknowledgments

- Inspired by the need to eliminate repetitive server setup tasks
- Built with automation and efficiency in mind
- Community feedback and contributions

## Support

If you encounter issues or have questions:

- 📫 Open an [issue](https://github.com/fmenis/node-server-bootstrap/issues)
- 💬 Start a [discussion](https://github.com/fmenis/node-server-bootstrap/discussions)
- ⭐ Star this repo if you find it helpful!

---

**Happy Provisioning!** 🎉

_Last updated: November 2025_
