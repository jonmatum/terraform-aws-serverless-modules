# Changelog

## [3.1.1](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v3.1.0...v3.1.1) (2026-02-27)


### Documentation

* add missing examples to README table ([3887168](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/3887168))

## [3.1.0](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v3.0.0...v3.1.0) (2026-02-27)


### Features

* add SQS and SNS examples ([6698b7f](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/6698b7f663021eca0315e36e4950df81be1d2301))
* add SQS and SNS modules ([8a6393c](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/8a6393c7b4c3aa0bcd5326375f5a2aa2d3c2df59))
* **agentcore-full:** add SQS queue integration for async processing ([863f042](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/863f042e42053dc53ef4590e78251f5e1d6992ff))
* **agentcore:** add comprehensive AgentCore example with all capabilities ([d094c79](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/d094c798758897aabf70b1b0a5e1bf8f28200406))
* **agentcore:** implement proper MCP JSON-RPC protocol ([c13d225](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/c13d2258a80ce064f11bde66331612cf8e1a40b3))
* **agentcore:** make all advanced features optional ([9b73688](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/9b7368831bb5b7f37c399359001bc5fcaf4b6e2d))
* **lambda:** add production-ready Lambda module with monitoring and reliability features ([9676f89](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/9676f89d8b0f4949370fa6e1f3b14a9f907a8e2a))
* **sqs-queue:** add comprehensive example with FIFO queue and DLQ ([522b50c](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/522b50c8120f07206417aa56442c5e7ca0a48706))


### Bug Fixes

* **agentcore-full:** configure Lambda MCP for gateway compatibility ([04816bf](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/04816bf088547cf06d8199607852c24817b4e444))
* **agentcore:** add random suffix to gateway target name to avoid conflicts ([bf186e5](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/bf186e5944503e1394206519b4c948d4800b59ad))
* **agentcore:** disable gateway targets and fix actions image tag ([6c8a7fd](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/6c8a7fd9ff37ccfb8834c3d664c654cabc7acd21))
* **agentcore:** improve deploy script and document OpenSearch requirement ([2662fc4](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/2662fc498548cb804b6c95c1f481080878522e10))
* **agentcore:** update deploy script to match standard format ([dd28708](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/dd287084959389592605ee7b12556e02fffbe581))
* **api-gateway-v1:** remove unused alb_listener_arn variable ([09a718e](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/09a718ef4332d65c0fdae0aac69e6e809b10b70b))
* standardize deploy scripts and convert diagrams to mermaid ([db3c411](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/db3c4114847d00d1c7359ae9e45bfed290c389bb))

## [3.0.0](https://github.com/jonmatum/terraform-aws-serverless-modules/compare/v2.1.0...v3.0.0) (2026-02-26)


### ⚠ BREAKING CHANGES

* Restructured ecs-app example with separate terraform/ and app/ directories

### Documentation

* improve Terraform Registry compatibility and architecture documentation ([350b88b](https://github.com/jonmatum/terraform-aws-serverless-modules/commit/350b88be0a4651c1466a5677a3df1dc2df1c6e08))

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
