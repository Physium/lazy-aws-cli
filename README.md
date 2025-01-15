# Lazy AWS CLI

Hate the idea of having to figure necessary inputs for aws cli query? No worries, me too.

## Getting Started

### Prerequisites
- Ruby 3.3.1 or higher
- AWS CLI configured with appropriate credentials

### 1. Clone repository
```bash
git clone git@github.com:Physium/lazy-aws-cli.git
cd laws
```

### 2. Install project dependencies
```bash
bundle install
```

### 3. Run the setup script
```bash
./setup.sh
```

The setup script will:
- Create a symlink to the laws executable in /usr/local/bin (default)
- Make the command available system-wide
- You can specify a different installation directory:
  INSTALL_DIR=~/bin ./setup.sh

To uninstall, simply run the setup script again and it will remove the symlink.
