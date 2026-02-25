output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS name"
  value       = aws_lb.nlb.dns_name
}

output "test_commands" {
  description = "Commands to test the service"
  value       = <<-EOT
    # Test the service
    curl ${aws_api_gateway_stage.prod.invoke_url}/api/hello

    # Test health check
    curl ${aws_api_gateway_stage.prod.invoke_url}/api/health

    # Test info endpoint
    curl ${aws_api_gateway_stage.prod.invoke_url}/api/info
  EOT
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}
