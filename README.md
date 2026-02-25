# ECS Terraform Module

Reusable Terraform module for deploying ECS services on AWS.

## Structure

```
.
├── modules/ecs/          # Reusable ECS module
├── examples/ecs-app/     # Consumer example
└── .github/workflows/    # CI/CD pipelines
```

## Quick Start

```bash
# Initial deployment
./deploy.sh

# Redeploy after code changes
./redeploy.sh
```

## Usage

See `examples/ecs-app/` for a complete implementation example.
