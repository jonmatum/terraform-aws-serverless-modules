output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.api_gateway.api_endpoint
}

output "fastapi_ecr_url" {
  description = "FastAPI ECR repository URL"
  value       = module.ecr_fastapi.repository_url
}

output "mcp_ecr_url" {
  description = "MCP ECR repository URL"
  value       = module.ecr_mcp.repository_url
}

output "ecs_fastapi_cluster_id" {
  description = "FastAPI ECS cluster ID"
  value       = module.ecs_fastapi.cluster_id
}

output "ecs_mcp_cluster_id" {
  description = "MCP ECS cluster ID"
  value       = module.ecs_mcp.cluster_id
}

output "test_commands" {
  description = "Commands to test the services"
  value = <<-EOT
    # Test FastAPI service
    curl ${module.api_gateway.api_endpoint}/api/fastapi
    
    # Test MCP service
    curl ${module.api_gateway.api_endpoint}/api/mcp
  EOT
}
