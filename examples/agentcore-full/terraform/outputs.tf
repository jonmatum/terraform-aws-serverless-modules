output "gateway_id" {
  description = "AgentCore Gateway ID"
  value       = aws_bedrockagentcore_gateway.main.gateway_id
}

output "gateway_arn" {
  description = "AgentCore Gateway ARN"
  value       = aws_bedrockagentcore_gateway.main.gateway_arn
}

output "agent_id" {
  description = "Bedrock Agent ID"
  value       = aws_bedrockagent_agent.assistant.agent_id
}

output "agent_alias_id" {
  description = "Bedrock Agent Alias ID"
  value       = aws_bedrockagent_agent_alias.live.agent_alias_id
}

output "knowledge_base_id" {
  description = "Knowledge Base ID"
  value       = aws_bedrockagent_knowledge_base.docs.id
}

output "data_source_id" {
  description = "Knowledge Base Data Source ID"
  value       = aws_bedrockagent_data_source.s3.data_source_id
}

output "kb_bucket_name" {
  description = "S3 bucket name for Knowledge Base documents"
  value       = aws_s3_bucket.kb_docs.id
}

output "ecs_mcp_endpoint" {
  description = "ECS MCP server endpoint (via ALB)"
  value       = "https://${module.alb.alb_dns_name}"
}

output "lambda_mcp_url" {
  description = "Lambda MCP server Function URL"
  value       = module.lambda_mcp.function_url
}

output "guardrail_id" {
  description = "Guardrail ID"
  value       = aws_bedrock_guardrail.content_filter.guardrail_id
}

output "guardrail_version" {
  description = "Guardrail Version"
  value       = aws_bedrock_guardrail_version.v1.version
}

output "ecr_ecs_url" {
  description = "ECR repository URL for ECS MCP server"
  value       = module.ecr_ecs.repository_url
}

output "ecr_lambda_url" {
  description = "ECR repository URL for Lambda functions"
  value       = module.ecr_lambda.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_mcp.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs_mcp.service_name
}

output "lambda_mcp_name" {
  description = "Lambda MCP function name"
  value       = module.lambda_mcp.function_name
}

output "lambda_actions_name" {
  description = "Lambda actions function name"
  value       = module.lambda_actions.function_name
}

output "test_commands" {
  description = "Commands to test the deployment"
  value = <<-EOT
    # Test Gateway
    aws bedrock-agentcore-runtime invoke-gateway \
      --gateway-identifier ${aws_bedrockagentcore_gateway.main.gateway_id} \
      --request-body '{"method":"tools/list"}' \
      --region ${var.aws_region}
    
    # Test Knowledge Base
    aws bedrock-agent-runtime retrieve \
      --knowledge-base-id ${aws_bedrockagent_knowledge_base.docs.id} \
      --retrieval-query '{"text":"What is our return policy?"}' \
      --region ${var.aws_region}
    
    # Test Agent
    aws bedrock-agent-runtime invoke-agent \
      --agent-id ${aws_bedrockagent_agent.assistant.agent_id} \
      --agent-alias-id ${aws_bedrockagent_agent_alias.live.agent_alias_id} \
      --session-id test-session-$(date +%s) \
      --input-text "What's the weather in Seattle?" \
      --region ${var.aws_region}
    
    # Upload documents to Knowledge Base
    aws s3 cp docs/ s3://${aws_s3_bucket.kb_docs.id}/docs/ --recursive
    
    # Sync Knowledge Base
    aws bedrock-agent start-ingestion-job \
      --knowledge-base-id ${aws_bedrockagent_knowledge_base.docs.id} \
      --data-source-id ${aws_bedrockagent_data_source.s3.data_source_id} \
      --region ${var.aws_region}
  EOT
}
