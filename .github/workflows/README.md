# GitHub Actions Workflows

## Active Workflows

### release-please.yml
Automatically creates release PRs and GitHub releases for each module when conventional commits are merged to main.

## Disabled Workflows (Documentation)

### deploy.yml.disabled
Example deployment workflow for ECS services. This workflow is disabled but kept as documentation.

To enable it:
```bash
mv .github/workflows/deploy.yml.disabled .github/workflows/deploy.yml
```

**Note:** This workflow requires the following secrets:
- `AWS_ROLE_ARN` - IAM role ARN for OIDC authentication
- `ECR_REPOSITORY` - ECR repository name

The workflow demonstrates:
- AWS OIDC authentication
- Docker image building and pushing to ECR
- Terraform deployment
- Integration with GitHub Actions
