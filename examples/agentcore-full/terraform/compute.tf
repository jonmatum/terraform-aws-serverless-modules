# ECS-based MCP Server
module "ecs_mcp" {
  source = "../../../modules/ecs"

  cluster_name       = "${var.project_name}-cluster"
  task_family        = "${var.project_name}-mcp-ecs"
  service_name       = "${var.project_name}-mcp-ecs"
  container_name     = "mcp-server"
  container_image    = "${module.ecr_ecs.repository_url}:latest"
  container_port     = 3000
  cpu                = "256"
  memory             = "512"
  desired_count      = 1
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
  target_group_arn   = module.alb.target_group_arn
  log_group_name     = aws_cloudwatch_log_group.ecs_mcp.name
  aws_region         = var.aws_region

  environment_variables = [
    { name = "PORT", value = "3000" },
    { name = "NODE_ENV", value = "production" }
  ]

  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 4
  enable_fargate_spot      = var.environment == "dev"
  fargate_spot_weight      = var.environment == "dev" ? 100 : 50

  tags = var.tags
}

# Lambda-based MCP Server
module "lambda_mcp" {
  source = "../../../modules/lambda"

  function_name      = "${var.project_name}-mcp-lambda"
  execution_role_arn = aws_iam_role.lambda_mcp.arn
  image_uri          = "${module.ecr_lambda.repository_url}:latest"
  timeout            = 30
  memory_size        = 512

  enable_function_url    = true
  function_url_auth_type = "AWS_IAM"

  # Production reliability
  dead_letter_config_target_arn = var.enable_dlq ? aws_sqs_queue.lambda_mcp_dlq[0].arn : null
  maximum_retry_attempts         = 2
  maximum_event_age_in_seconds   = 21600
  enable_xray                    = var.enable_xray

  environment_variables = {
    ENVIRONMENT = var.environment
  }

  tags = var.tags
}

# Action Lambda for Agent
module "lambda_actions" {
  source = "../../../modules/lambda"

  function_name      = "${var.project_name}-actions"
  execution_role_arn = aws_iam_role.lambda_actions.arn
  image_uri          = "${module.ecr_lambda.repository_url}:actions"
  timeout            = 30
  memory_size        = 256

  # Production reliability
  dead_letter_config_target_arn = var.enable_dlq ? aws_sqs_queue.lambda_actions_dlq[0].arn : null
  maximum_retry_attempts         = 2
  maximum_event_age_in_seconds   = 21600
  enable_xray                    = var.enable_xray

  environment_variables = {
    ENVIRONMENT = var.environment
  }

  tags = var.tags
}

# DLQ for Lambda MCP
resource "aws_sqs_queue" "lambda_mcp_dlq" {
  count                     = var.enable_dlq ? 1 : 0
  name                      = "${var.project_name}-lambda-mcp-dlq"
  message_retention_seconds = 1209600

  tags = var.tags
}

# DLQ for Lambda Actions
resource "aws_sqs_queue" "lambda_actions_dlq" {
  count                     = var.enable_dlq ? 1 : 0
  name                      = "${var.project_name}-lambda-actions-dlq"
  message_retention_seconds = 1209600

  tags = var.tags
}
