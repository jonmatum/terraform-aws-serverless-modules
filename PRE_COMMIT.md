# Pre-commit Setup

This repository uses [pre-commit](https://pre-commit.com/) to automatically format and validate Terraform code.

## Installation

### 1. Install pre-commit

```bash
# macOS
brew install pre-commit

# Linux
pip install pre-commit

# Or using pip
pip3 install pre-commit
```

### 2. Install terraform-docs

```bash
# macOS
brew install terraform-docs

# Linux
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.17.0/terraform-docs-v0.17.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/
```

### 3. Install tflint

```bash
# macOS
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

### 4. Install the git hooks

```bash
pre-commit install
```

## Usage

Pre-commit will automatically run on `git commit`. To run manually:

```bash
# Run on all files
pre-commit run --all-files

# Run on specific files
pre-commit run --files modules/vpc/*.tf
```

## What it does

- **terraform_fmt**: Formats Terraform files
- **terraform_docs**: Generates documentation in README.md files
- **terraform_validate**: Validates Terraform configuration
- **terraform_tflint**: Lints Terraform code
- **trailing-whitespace**: Removes trailing whitespace
- **end-of-file-fixer**: Ensures files end with newline
- **check-yaml**: Validates YAML files
- **check-added-large-files**: Prevents large files from being committed
- **check-merge-conflict**: Checks for merge conflict markers

## Skipping hooks

To skip hooks for a specific commit:

```bash
git commit --no-verify
```

## Updating hooks

```bash
pre-commit autoupdate
```
