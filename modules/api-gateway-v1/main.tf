resource "aws_api_gateway_rest_api" "this" {
  name = var.name

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.name}-vpc-link"
  target_arns = [aws_lb.nlb.arn]

  tags = var.tags
}

resource "aws_lb" "nlb" {
  name               = "${var.name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.vpc_link_subnet_ids

  tags = var.tags
}

resource "aws_api_gateway_resource" "this" {
  for_each = var.integrations

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "this" {
  for_each = var.integrations

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  for_each = var.integrations

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.this[each.key].http_method

  type                    = "HTTP_PROXY"
  integration_http_method = each.value.http_method
  uri                     = each.value.integration_uri
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this,
  ]
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  tags = var.tags
}
