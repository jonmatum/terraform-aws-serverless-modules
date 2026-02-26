output "api_id" {
  description = "API Gateway REST API ID"
  value       = local.use_openapi ? aws_api_gateway_rest_api.openapi[0].id : aws_api_gateway_rest_api.legacy[0].id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.this.arn
}

output "vpc_link_id" {
  description = "VPC Link ID"
  value       = aws_api_gateway_vpc_link.this[0].id
}

output "nlb_arn" {
  description = "Network Load Balancer ARN"
  value       = aws_lb.nlb[0].arn
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS name"
  value       = aws_lb.nlb[0].dns_name
}
