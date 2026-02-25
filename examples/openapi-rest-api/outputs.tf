output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}"
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.this.id
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
  value = <<-EOT
    API_ENDPOINT=${aws_api_gateway_stage.prod.invoke_url}
    
    # List all products
    curl $API_ENDPOINT/products
    
    # Get specific product
    curl $API_ENDPOINT/products/1
    
    # Create product
    curl -X POST $API_ENDPOINT/products \
      -H "Content-Type: application/json" \
      -d '{"name":"Laptop","price":999.99,"stock":10}'
    
    # Update product
    curl -X PUT $API_ENDPOINT/products/1 \
      -H "Content-Type: application/json" \
      -d '{"price":899.99}'
    
    # Delete product
    curl -X DELETE $API_ENDPOINT/products/2
    
    # View OpenAPI docs
    echo "OpenAPI spec: ${path.module}/openapi.json"
  EOT
}
