output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.api_gateway.api_endpoint
}

output "api_docs_url" {
  description = "API documentation URL (FastAPI Swagger)"
  value       = "${module.api_gateway.api_endpoint}/docs"
}

output "cloudfront_url" {
  description = "CloudFront distribution URL for React app"
  value       = module.cloudfront.cloudfront_url
}

output "s3_bucket_name" {
  description = "S3 bucket name for React app deployment"
  value       = module.cloudfront.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "test_commands" {
  description = "Commands to test the API"
  value       = <<-EOT
    # Set API endpoint
    export API_URL=${module.api_gateway.api_endpoint}

    # Create an item
    curl -X POST $API_URL/items \
      -H "Content-Type: application/json" \
      -d '{"name": "Laptop", "description": "MacBook Pro", "price": 2499.99, "quantity": 10}'

    # List all items
    curl $API_URL/items

    # Get specific item
    curl $API_URL/items/{item-id}

    # Update item
    curl -X PUT $API_URL/items/{item-id} \
      -H "Content-Type: application/json" \
      -d '{"price": 2299.99}'

    # Delete item
    curl -X DELETE $API_URL/items/{item-id}

    # Health check
    curl $API_URL/health

    # Open API documentation
    open $API_URL/docs
  EOT
}
