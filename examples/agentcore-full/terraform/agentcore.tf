resource "random_id" "suffix" {
  byte_length = 4
}

# AgentCore Gateway with Guardrails
resource "aws_bedrockagentcore_gateway" "main" {
  name        = "${var.project_name}-gateway"
  description = "Comprehensive AgentCore Gateway with multiple targets"
  role_arn    = aws_iam_role.gateway.arn

  authorizer_type = "AWS_IAM"
  protocol_type   = "MCP"

  protocol_configuration {
    mcp {
      instructions       = "Multi-target gateway for MCP servers, Knowledge Base, and Bedrock Agent"
      search_type        = "SEMANTIC"
      supported_versions = ["2025-03-26"]
    }
  }

  tags = var.tags
}

# Gateway Target: Lambda MCP Server
resource "random_id" "target_suffix" {
  byte_length = 4
}

resource "aws_bedrockagentcore_gateway_target" "lambda_mcp" {
  gateway_identifier = aws_bedrockagentcore_gateway.main.gateway_id
  name               = "lambda-mcp-${random_id.target_suffix.hex}"
  description        = "Lambda-based MCP server"

  target_configuration {
    mcp {
      mcp_server {
        endpoint = module.lambda_mcp.function_url
      }
    }
  }
}
