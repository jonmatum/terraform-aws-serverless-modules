# Changelog

## [2.1.0](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v2.0.1...v2.1.0) (2026-02-26)


### Features

* **mcp-agent-runtime:** update MCP server to use proper SDK schemas and unified endpoint ([460bcff](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/460bcff9305ebfb59244fa748275c1ffbc5ad9b9))

## [2.0.1](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v2.0.0...v2.0.1) (2026-02-26)


### Bug Fixes

* **openapi-rest-api:** use Docker for OpenAPI generation and fix schema conversion ([caebdc7](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/caebdc72a0bcb6ee1da2cf9fb0121d4964cc2625))

## [2.0.0](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v1.0.0...v2.0.0) (2026-02-26)


### ⚠ BREAKING CHANGES

* **api-gateway-v1:** Module now requires vpc_id and alb_arn when using OpenAPI mode with ALB
* **api-gateway:** api-gateway-v1 now requires alb_arn, vpc_id, and health_check_path when using OpenAPI mode with ALB

### Features

* **ecs-app:** add deployment scripts for Docker image build and push ([54114c7](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/54114c76ece4dc96204f7fc629c60e6bdd41d802))
* **examples:** add crud-api-http with optimized HTTP API (v2) ([6558e39](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/6558e39f2d6e3f284817bdf9c55f9b1f3f507e4f))


### Bug Fixes

* add cluster_name outputs to all examples for deployment scripts ([b72d474](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/b72d474025186334924fed26e48ac478d17e5a4c))
* **api-gateway-v1:** implement NLB-to-ALB bridge for REST API VPC Link ([a96e513](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/a96e513261b4de9821cf1a90a720a169134da326))
* **api-gateway:** correct VPC Link architecture and health checks ([f8c0ca6](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/f8c0ca62111ebe46cc0d3f96de2685ff1838f885))
* **crud-api-rest:** update example for api-gateway-v1 module changes ([2803e2e](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/2803e2e55a4ec24494d166063974f516926577ac))
* **ecs-app:** create ECR repository before pushing image ([ef53816](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/ef538168fc6d220e2897142c8810b12aba3ea8ab))
* **ecs-app:** simplify deploy script ([c2d34ae](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/c2d34ae31e4b357236461df68ee5b83ee16e91f8))
* **ecs:** add cluster_name output to ECS module ([268109e](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/268109e7946210103fad849948d8cbc9aae50388))
* **examples:** correct deployment scripts for cross-platform compatibility and proper deployment order ([2132174](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/2132174a3cf4b623849a53079acc7b3256523896))

## [1.0.0](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v0.1.0...v1.0.0) (2026-02-25)


### ⚠ BREAKING CHANGES

* **mcp-agent-runtime:** Requires AWS provider >= 6.18.0 for AgentCore resources
* Removed internal documentation files (CRUD_COMPLETE, IMPLEMENTATION_SUMMARY, etc.)

### Features

* add API Gateway multi-service example with smart deployment scripts ([fe05d18](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/fe05d18cb97aec2309ce80afeeb77fbb614b3ad0))
* add OpenAPI schema-driven API Gateway examples for v1 and v2 ([330c4c1](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/330c4c1e1cc8fe22ffd73f38e92f877898894f02))
* add REST API Gateway (v1) module and example ([85cdb6c](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/85cdb6c631a8ce86597c5ff9a5dad1b44eb9a42f))
* add root-level release tracking ([7126c92](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/7126c9266f7d9eb6f4671045bf492b880be4f52d))
* **mcp-agent-runtime:** add AWS Bedrock AgentCore Gateway integration ([6519028](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/6519028b667bf15216e9b338c746c98cf0769ba4))
* upgrade to AWS Provider v6.0 and implement AgentCore Gateway ([3aa1177](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/3aa11773f6f95bb392d59b14ea2ef614cb692267))


### Bug Fixes

* **ci:** add api-gateway modules to release manifest ([706e263](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/706e263006b295b5832a784530dcdf22e59e7578))
* **ci:** simplify release-please config for Terraform Registry ([6ea403d](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/6ea403dba3810db902095dd817876fd12425a9c8))
* **ci:** update bootstrap SHA to include all feature commits ([96aa5bb](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/96aa5bb80e1fadb16a7ee9bcdd5cefb40dbc8539))
* **ci:** use full SHA for bootstrap commit ([27f573f](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/27f573f2755f97ac40bee81e218ea419fe1ebbc4))
* **deps:** update all dependencies to resolve security vulnerabilities ([4632351](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/4632351d85c44e60e72871505060b47506b70706))
* **deps:** update dependencies to resolve security vulnerabilities ([6a2b242](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/6a2b242ccbf60b1973096d9553ee64304cf4789b))


### Documentation

* streamline documentation for user clarity ([b7faaea](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/b7faaea2482b1194b7511f1fcc6051e619e878ab))
