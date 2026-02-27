# Bedrock Agent
resource "aws_bedrockagent_agent" "assistant" {
  count = var.enable_agent ? 1 : 0
  agent_name              = "${var.project_name}-assistant"
  agent_resource_role_arn = aws_iam_role.agent[0].arn
  foundation_model        = var.agent_model
  instruction             = var.agent_instruction

  tags = var.tags
}

# Agent Alias
resource "aws_bedrockagent_agent_alias" "live" {
  count = var.enable_agent ? 1 : 0
  agent_id         = aws_bedrockagent_agent.assistant[0].agent_id
  agent_alias_name = "live"
  description      = "Live production alias"
}

# Action Group for API integrations
resource "aws_bedrockagent_agent_action_group" "api_actions" {
  count = var.enable_agent ? 1 : 0
  agent_id          = aws_bedrockagent_agent.assistant[0].agent_id
  agent_version     = "DRAFT"
  action_group_name = "api-actions"

  action_group_executor {
    lambda = module.lambda_actions.function_arn
  }

  api_schema {
    payload = jsonencode({
      openapi = "3.0.0"
      info = {
        title   = "API Actions"
        version = "1.0.0"
      }
      paths = {
        "/weather" = {
          get = {
            summary     = "Get weather information"
            description = "Get current weather for a location"
            operationId = "getWeather"
            parameters = [{
              name        = "location"
              in          = "query"
              description = "City name or zip code"
              required    = true
              schema = {
                type = "string"
              }
            }]
            responses = {
              "200" = {
                description = "Weather information"
                content = {
                  "application/json" = {
                    schema = {
                      type = "object"
                      properties = {
                        temperature = { type = "number" }
                        conditions  = { type = "string" }
                        humidity    = { type = "number" }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        "/database/query" = {
          post = {
            summary     = "Query database"
            description = "Execute a database query"
            operationId = "queryDatabase"
            requestBody = {
              required = true
              content = {
                "application/json" = {
                  schema = {
                    type = "object"
                    properties = {
                      query = { type = "string" }
                    }
                    required = ["query"]
                  }
                }
              }
            }
            responses = {
              "200" = {
                description = "Query results"
                content = {
                  "application/json" = {
                    schema = {
                      type = "object"
                      properties = {
                        results = { type = "array" }
                        count   = { type = "number" }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    })
  }
}

# Associate Knowledge Base with Agent
resource "aws_bedrockagent_agent_knowledge_base_association" "docs" {
  count = var.enable_agent ? 1 : 0
  agent_id             = aws_bedrockagent_agent.assistant[0].agent_id
  agent_version        = "DRAFT"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.docs[0].id
  knowledge_base_state = "ENABLED"
  description          = "Company documentation knowledge base"
}


