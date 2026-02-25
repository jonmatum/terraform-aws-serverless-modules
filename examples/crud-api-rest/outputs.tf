output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.api_gateway_rest.api_endpoint
}

output "api_docs_url" {
  description = "API documentation URL (FastAPI Swagger)"
  value       = "${module.api_gateway_rest.api_endpoint}/docs"
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "cloudfront_url" {
  description = "CloudFront distribution URL for React app"
  value       = module.cloudfront.website_url
}

output "s3_bucket_name" {
  description = "S3 bucket name for React app deployment"
  value       = module.cloudfront.bucket_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_id
}

output "service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "test_commands" {
  description = "Commands to test the API"
  value = <<-EOT
    # Test API
    export API_URL="${module.api_gateway_rest.api_endpoint}"
    
    # Create item
    curl -X POST $API_URL/items -H "Content-Type: application/json" -d '{"name":"Test Item","description":"Test","price":29.99,"quantity":100}'
    
    # List items
    curl $API_URL/items
    
    # Health check
    curl $API_URL/health
    
    # API Documentation
    open ${module.api_gateway_rest.api_endpoint}/docs
  EOT
}
