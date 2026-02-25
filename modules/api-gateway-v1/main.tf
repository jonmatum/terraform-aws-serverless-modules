locals {
  use_openapi = var.openapi_spec != null
  use_nlb     = !local.use_openapi
}

# REST API - OpenAPI mode
resource "aws_api_gateway_rest_api" "openapi" {
  count       = local.use_openapi ? 1 : 0
  name        = var.name
  description = "REST API for ${var.name}"

  body = replace(
    var.openapi_spec,
    "$${vpc_link_id}",
    aws_api_gateway_vpc_link.alb[0].id
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# REST API - Legacy mode
resource "aws_api_gateway_rest_api" "legacy" {
  count = local.use_nlb ? 1 : 0
  name  = var.name

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# VPC Link for ALB (OpenAPI mode)
resource "aws_api_gateway_vpc_link" "alb" {
  count       = local.use_openapi ? 1 : 0
  name        = "${var.name}-vpc-link"
  target_arns = [var.alb_listener_arn]

  tags = var.tags
}

# NLB for VPC Link (Legacy mode)
resource "aws_lb" "nlb" {
  count              = local.use_nlb ? 1 : 0
  name               = "${var.name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.vpc_link_subnet_ids

  tags = var.tags
}

# VPC Link for NLB (Legacy mode)
resource "aws_api_gateway_vpc_link" "nlb" {
  count       = local.use_nlb ? 1 : 0
  name        = "${var.name}-vpc-link"
  target_arns = [aws_lb.nlb[0].arn]

  tags = var.tags
}

# Legacy mode resources
resource "aws_api_gateway_resource" "this" {
  for_each = local.use_nlb ? var.integrations : {}

  rest_api_id = aws_api_gateway_rest_api.legacy[0].id
  parent_id   = aws_api_gateway_rest_api.legacy[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "this" {
  for_each = local.use_nlb ? var.integrations : {}

  rest_api_id   = aws_api_gateway_rest_api.legacy[0].id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  for_each = local.use_nlb ? var.integrations : {}

  rest_api_id = aws_api_gateway_rest_api.legacy[0].id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.this[each.key].http_method

  type                    = "HTTP_PROXY"
  integration_http_method = each.value.http_method
  uri                     = each.value.integration_uri
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.nlb[0].id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = local.use_openapi ? aws_api_gateway_rest_api.openapi[0].id : aws_api_gateway_rest_api.legacy[0].id

  triggers = {
    redeployment = local.use_openapi ? sha1(jsonencode(aws_api_gateway_rest_api.openapi[0].body)) : sha1(jsonencode([
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api.openapi,
    aws_api_gateway_rest_api.legacy,
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this,
  ]
}

# Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = local.use_openapi ? aws_api_gateway_rest_api.openapi[0].id : aws_api_gateway_rest_api.legacy[0].id
  stage_name    = var.stage_name

  xray_tracing_enabled = var.enable_xray_tracing

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
      })
    }
  }

  tags = var.tags
}

# Method settings
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = local.use_openapi ? aws_api_gateway_rest_api.openapi[0].id : aws_api_gateway_rest_api.legacy[0].id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = false
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.name}"
  retention_in_days = 30

  tags = var.tags
}

# IAM role for CloudWatch Logs
resource "aws_iam_role" "api_gateway_cloudwatch" {
  count = var.enable_access_logs ? 1 : 0
  name  = "${var.name}-api-gateway-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch" {
  count = var.enable_access_logs ? 1 : 0
  name  = "${var.name}-api-gateway-cloudwatch"
  role  = aws_iam_role.api_gateway_cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# API Gateway account settings
resource "aws_api_gateway_account" "this" {
  count               = var.enable_access_logs ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch[0].arn
}

