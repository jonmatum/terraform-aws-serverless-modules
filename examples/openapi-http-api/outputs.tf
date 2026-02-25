output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.this.id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "openapi_spec_location" {
  description = "Location of generated OpenAPI spec"
  value       = "${path.module}/openapi.json"
}

output "test_commands" {
  description = "Commands to test the API"
  value       = <<-EOT
    API_ENDPOINT=${aws_apigatewayv2_api.this.api_endpoint}

    # List all users
    curl $API_ENDPOINT/users

    # Get specific user
    curl $API_ENDPOINT/users/1

    # Create user
    curl -X POST $API_ENDPOINT/users \
      -H "Content-Type: application/json" \
      -d '{"name":"Alice","email":"alice@example.com"}'

    # Update user
    curl -X PUT $API_ENDPOINT/users/1 \
      -H "Content-Type: application/json" \
      -d '{"name":"John Updated"}'

    # Delete user
    curl -X DELETE $API_ENDPOINT/users/2

    # View OpenAPI docs
    echo "OpenAPI spec: ${path.module}/openapi.json"
  EOT
}
