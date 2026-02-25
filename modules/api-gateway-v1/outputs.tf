output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "vpc_link_id" {
  description = "VPC Link ID"
  value       = aws_api_gateway_vpc_link.this.id
}

output "nlb_arn" {
  description = "Network Load Balancer ARN"
  value       = aws_lb.nlb.arn
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS name"
  value       = aws_lb.nlb.dns_name
}
