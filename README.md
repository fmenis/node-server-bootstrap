# NodeJs Server Bootstrap 🚀

A comprehensive provisioning repository to automate software installation and configuration for Node.js server environments. Say goodbye to repetitive manual setup!

## Overview

This repository provides automated scripts and configurations to quickly bootstrap a Node.js server with all necessary dependencies, tools, and configurations. Perfect for setting up new development environments, CI/CD pipelines, or production servers.

## Features

- ✅ Automated software installation
- ✅ Pre-configured development tools
- ✅ Consistent environment setup across machines
- ✅ Version-controlled configuration files
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

2. **Make startup executable**

   ```bash
   chmod +x startup.sh
   ```

3. **Follow the on-screen prompts** (if any) to complete the setup

## What Gets Installed

The provisioning process typically includes:

- **Node.js** - Latest LTS version
- **npm** - Package managers
- **Git** - Version control
- **Development tools** - Essential build tools and compilers
- **Common utilities** - curl, wget, vim, etc.
- **Security updates** - Latest system patches

## Project Structure

```
node-server-bootstrap/
├── provision.sh          # Main provisioning script
├── scripts/              # Individual setup scripts
├── templates/            # Configuration templates
└── README.md             # This file
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

## Roadmap

- [ ] Add configuration templates
- [ ] Ask main software (nodejs, postgres, etc) version (default last LTS)
- [ ] Add rollback functionality

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Filippo Menis** ([@fmenis](https://github.com/fmenis))

**Happy Provisioning!** 🎉

_Last updated: November 2025_
