# Contributing Guide

## Development Workflow

### Prerequisites

```bash
# Install pre-commit
pip install pre-commit

# Install pre-commit hooks
pre-commit install
```

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Update Terraform code
   - Update examples if needed
   - Add tests if applicable

3. **Run pre-commit hooks**
   ```bash
   # Run all hooks
   pre-commit run --all-files
   
   # Or run specific hooks
   pre-commit run terraform_fmt --all-files
   pre-commit run terraform_docs --all-files
   ```

4. **Test your changes**
   ```bash
   # Test all modules
   ./scripts/test-modules.sh
   
   # Test specific example
   cd examples/your-example
   ./deploy.sh
   terraform destroy -auto-approve
   ```

5. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   git push origin feature/your-feature-name
   ```

## Pre-commit Hooks

The repository uses pre-commit hooks to ensure code quality and consistency.

### Automatic Actions

When you commit, the following happens automatically:

1. **terraform_fmt**: Formats all Terraform files
2. **terraform_docs**: Generates/updates README.md for all modules and examples
3. **terraform_validate**: Validates Terraform syntax
4. **terraform_tflint**: Runs linting checks
5. **trailing-whitespace**: Removes trailing whitespace
6. **end-of-file-fixer**: Ensures files end with newline
7. **check-yaml**: Validates YAML syntax
8. **check-added-large-files**: Prevents large files from being committed
9. **check-merge-conflict**: Checks for merge conflict markers

### Manual Documentation Update

If you need to manually update documentation:

```bash
# Update all module documentation
pre-commit run terraform_docs --all-files

# Update specific module
cd modules/vpc
terraform-docs markdown table --output-file README.md --output-mode inject .

# Update specific example
cd examples/ecs-app
terraform-docs markdown table --output-file README.md --output-mode inject .
```

## Documentation Standards

### Module README Structure

Each module should have a README.md with:

1. **Description**: Brief overview of the module
2. **Usage**: Basic usage example
3. **Features**: Key features and capabilities
4. **Examples**: Link to examples
5. **Auto-generated docs**: Terraform docs (requirements, providers, inputs, outputs)

### Example README Structure

Each example should have a README.md with:

1. **Description**: What the example demonstrates
2. **Architecture**: Mermaid diagram showing the architecture
3. **Deployment**: Step-by-step deployment instructions
4. **Testing**: How to test the deployed resources
5. **Cleanup**: How to destroy resources
6. **Auto-generated docs**: Terraform docs

### Mermaid Diagrams

Use Mermaid diagrams to visualize architectures:

```markdown
## Architecture

\`\`\`mermaid
graph LR
    Client[Client] --> ALB[Load Balancer]
    ALB --> ECS[ECS Tasks]
    ECS --> DDB[DynamoDB]
\`\`\`
```

### Code Style

- **No emojis**: Use plain text in code and documentation
- **Consistent naming**: Use snake_case for variables, kebab-case for resources
- **Comments**: Add comments for complex logic
- **Error messages**: Use clear, actionable error messages

## Testing

### Module Testing

```bash
# Test all modules
./scripts/test-modules.sh

# Test specific module
cd modules/vpc
terraform init
terraform validate
terraform fmt -check
```

### Example Testing

```bash
# Test idempotency
./scripts/test-idempotency.sh example-name

# Manual testing
cd examples/example-name
./deploy.sh
# Test functionality
terraform destroy -auto-approve
```

### Integration Testing

```bash
# Deploy, test, and destroy
cd examples/example-name
./deploy.sh
curl $(terraform output -raw endpoint)
terraform destroy -auto-approve
```

## Commit Message Convention

Use conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add support for Fargate Spot in ECS module
fix: correct IAM policy for ECR access
docs: update VPC module README with examples
```

## Pull Request Process

1. **Update documentation**: Ensure all docs are up to date
2. **Run tests**: All tests must pass
3. **Update CHANGELOG**: Add entry for your changes
4. **Request review**: Tag relevant reviewers
5. **Address feedback**: Make requested changes
6. **Merge**: Squash and merge when approved

## Release Process

1. **Update version**: Bump version in relevant files
2. **Update CHANGELOG**: Document all changes
3. **Create tag**: `git tag -a v2.0.2 -m "Release v2.0.2"`
4. **Push tag**: `git push origin v2.0.2`
5. **Create release**: Create GitHub release with notes

## Questions?

Open an issue or discussion on GitHub.
