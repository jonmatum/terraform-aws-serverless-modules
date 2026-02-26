output "gateway_url" {
  description = "AgentCore Gateway URL"
  value       = aws_bedrockagentcore_gateway.mcp.gateway_url
}

output "gateway_id" {
  description = "AgentCore Gateway ID"
  value       = aws_bedrockagentcore_gateway.mcp.gateway_id
}

output "alb_dns_name" {
  description = "ALB DNS name (internal)"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = "${var.project_name}-cluster"
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "test_commands" {
  description = "Commands to test the MCP server"
  value       = <<-EOT
    # Get Gateway URL
    GATEWAY_URL=$(terraform output -raw gateway_url)

    # Test via AWS CLI (requires AWS IAM authentication)
    aws bedrock-agentcore-runtime invoke-gateway \
      --gateway-identifier $(terraform output -raw gateway_id) \
      --request-body '{"method":"tools/list"}' \
      --region ${var.aws_region}

    # Direct ALB access (for debugging)
    curl http://${module.alb.alb_dns_name}/health
  EOT
}
