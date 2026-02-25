output "api_endpoint" {
  description = "Agent Gateway API endpoint"
  value       = module.api_gateway.api_endpoint
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
    # Health check
    curl ${module.api_gateway.api_endpoint}/health

    # List available tools
    curl -X POST ${module.api_gateway.api_endpoint}/mcp/tools/list

    # Call echo tool
    curl -X POST ${module.api_gateway.api_endpoint}/mcp/tools/call \
      -H "Content-Type: application/json" \
      -d '{"name": "echo", "arguments": {"message": "Hello from MCP!"}}'

    # Get system info
    curl -X POST ${module.api_gateway.api_endpoint}/mcp/tools/call \
      -H "Content-Type: application/json" \
      -d '{"name": "get_system_info", "arguments": {}}'
  EOT
}
