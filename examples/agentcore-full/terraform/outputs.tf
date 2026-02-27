output "gateway_id" {
  description = "AgentCore Gateway ID"
  value       = aws_bedrockagentcore_gateway.main.gateway_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_mcp.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs_mcp.service_name
}

output "agent_id" {
  description = "Bedrock Agent ID"
  value       = var.enable_agent ? aws_bedrockagent_agent.assistant[0].agent_id : null
}

output "agent_alias_id" {
  description = "Bedrock Agent Alias ID"
  value       = var.enable_agent ? aws_bedrockagent_agent_alias.live[0].agent_alias_id : null
}

output "knowledge_base_id" {
  description = "Knowledge Base ID"
  value       = var.enable_knowledge_base ? aws_bedrockagent_knowledge_base.docs[0].id : null
}

output "data_source_id" {
  description = "Data Source ID"
  value       = var.enable_knowledge_base ? aws_bedrockagent_data_source.s3[0].data_source_id : null
}

output "kb_bucket_name" {
  description = "S3 bucket for Knowledge Base documents"
  value       = var.enable_knowledge_base ? aws_s3_bucket.kb_docs[0].id : null
}

output "ecr_ecs_repository_url" {
  description = "ECR repository URL for ECS"
  value       = module.ecr_ecs.repository_url
}

output "ecr_lambda_repository_url" {
  description = "ECR repository URL for Lambda"
  value       = module.ecr_lambda.repository_url
}

output "ecr_actions_repository_url" {
  description = "ECR repository URL for Actions Lambda"
  value       = module.ecr_lambda.repository_url
}

output "guardrail_id" {
  description = "Guardrail ID"
  value       = var.enable_guardrails ? aws_bedrock_guardrail.content_filter[0].guardrail_id : null
}

output "guardrail_version" {
  description = "Guardrail version"
  value       = var.enable_guardrails ? aws_bedrock_guardrail_version.v1[0].version : null
}

output "lambda_mcp_url" {
  description = "Lambda MCP function URL"
  value       = module.lambda_mcp.function_url
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}
