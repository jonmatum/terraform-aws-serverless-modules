terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.name}-vpc-link"
  security_group_ids = var.vpc_link_security_group_ids
  subnet_ids         = var.vpc_link_subnet_ids

  tags = var.tags
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "this" {
  for_each = var.integrations

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = each.value.method
  integration_uri    = each.value.uri
  connection_type    = each.value.connection_type
  connection_id      = each.value.connection_type == "VPC_LINK" ? aws_apigatewayv2_vpc_link.this.id : null
}

resource "aws_apigatewayv2_route" "this" {
  for_each = var.integrations

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = var.enable_xray_tracing
    throttling_burst_limit   = var.enable_throttling ? var.throttle_burst_limit : null
    throttling_rate_limit    = var.enable_throttling ? var.throttle_rate_limit : null
  }

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
      format = jsonencode({
        requestId        = "$context.requestId"
        ip               = "$context.identity.sourceIp"
        requestTime      = "$context.requestTime"
        httpMethod       = "$context.httpMethod"
        routeKey         = "$context.routeKey"
        status           = "$context.status"
        protocol         = "$context.protocol"
        responseLength   = "$context.responseLength"
        errorMessage     = "$context.error.message"
        integrationError = "$context.integrationErrorMessage"
      })
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.name}"
  retention_in_days = 30

  tags = var.tags
}
