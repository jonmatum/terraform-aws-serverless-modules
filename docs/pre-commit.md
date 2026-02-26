# Pre-commit Hooks Quick Reference

## Installation

```bash
# Install pre-commit
pip install pre-commit

# Install hooks in repository
cd /path/to/terraform-aws-serverless-modules
pre-commit install
```

## Usage

### Automatic (on commit)

Pre-commit hooks run automatically when you commit:

```bash
git add .
git commit -m "feat: add new feature"
# Hooks run automatically
```

### Manual Execution

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook on all files
pre-commit run terraform_fmt --all-files
pre-commit run terraform_docs --all-files
pre-commit run terraform_validate --all-files

# Run hooks on staged files only
pre-commit run
```

## Hooks Configured

### 1. terraform_fmt
**Purpose**: Formats Terraform code to canonical style

**What it does**:
- Rewrites Terraform files to consistent format
- Fixes indentation, spacing, and alignment

**Manual equivalent**:
```bash
terraform fmt -recursive
```

### 2. terraform_docs
**Purpose**: Generates/updates module documentation

**What it does**:
- Scans Terraform files for inputs, outputs, providers, requirements
- Generates markdown tables in README.md
- Injects between `<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->` and `<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->`

**Manual equivalent**:
```bash
cd modules/vpc
terraform-docs markdown table --output-file README.md --output-mode inject .
```

**Configuration**:
- `--path-to-file=README.md`: Target file
- `--add-to-existing-file=true`: Update existing file
- `--create-file-if-not-exists=true`: Create if missing

### 3. terraform_validate
**Purpose**: Validates Terraform syntax

**What it does**:
- Checks for syntax errors
- Validates resource configurations
- Ensures proper Terraform structure

**Manual equivalent**:
```bash
terraform init -backend=false
terraform validate
```

### 4. terraform_tflint
**Purpose**: Lints Terraform code

**What it does**:
- Checks for deprecated syntax
- Identifies potential errors
- Enforces best practices

**Manual equivalent**:
```bash
tflint --config=.tflint.hcl
```

### 5. trailing-whitespace
**Purpose**: Removes trailing whitespace from files

### 6. end-of-file-fixer
**Purpose**: Ensures files end with newline

### 7. check-yaml
**Purpose**: Validates YAML syntax

### 8. check-added-large-files
**Purpose**: Prevents committing large files (>500KB)

### 9. check-merge-conflict
**Purpose**: Checks for merge conflict markers

## Troubleshooting

### Hook fails with "command not found"

**Problem**: Required tool not installed

**Solution**:
```bash
# Install terraform-docs
brew install terraform-docs

# Install tflint
brew install tflint

# Or use pre-commit's auto-install
pre-commit install-hooks
```

### terraform_docs not updating README

**Problem**: Missing markers in README.md

**Solution**: Add these markers to your README.md:
```markdown
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
```

### Hook takes too long

**Problem**: Running on all files is slow

**Solution**: Run on staged files only:
```bash
git add specific-file.tf
pre-commit run
```

### Skip hooks temporarily

```bash
# Skip all hooks for one commit
git commit --no-verify -m "message"

# Skip specific hook
SKIP=terraform_validate git commit -m "message"
```

## Best Practices

1. **Run before committing**: Always run `pre-commit run --all-files` before pushing
2. **Keep hooks updated**: Run `pre-commit autoupdate` periodically
3. **Don't skip hooks**: Only use `--no-verify` in emergencies
4. **Review changes**: Check what hooks modified before committing
5. **Update documentation**: Let terraform_docs handle it automatically

## CI/CD Integration

Add to GitHub Actions:

```yaml
name: Pre-commit
on: [push, pull_request]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
      - uses: pre-commit/action@v3.0.0
```

## Configuration File

Location: `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.88.4
    hooks:
      - id: terraform_fmt
      - id: terraform_docs
        args:
          - --hook-config=--path-to-file=README.md
          - --hook-config=--add-to-existing-file=true
          - --hook-config=--create-file-if-not-exists=true
      - id: terraform_validate
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
```

## Resources

- [pre-commit documentation](https://pre-commit.com/)
- [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform)
- [terraform-docs](https://terraform-docs.io/)
- [tflint](https://github.com/terraform-linters/tflint)
