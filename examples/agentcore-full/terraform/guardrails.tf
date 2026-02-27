# Guardrails for content filtering
resource "aws_bedrock_guardrail" "content_filter" {
  count = var.enable_guardrails ? 1 : 0
  name                      = "${var.project_name}-guardrail"
  blocked_input_messaging   = "Sorry, I cannot process that request due to content policy."
  blocked_outputs_messaging = "Sorry, I cannot provide that response due to content policy."
  description               = "Content filtering and topic blocking"

  # Content filters
  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "HATE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "VIOLENCE"
    }
    filters_config {
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
      type            = "SEXUAL"
    }
    filters_config {
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
      type            = "INSULTS"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "MISCONDUCT"
    }
  }

  # Topic policies
  topic_policy_config {
    topics_config {
      name       = "financial-advice"
      definition = "Providing specific financial or investment advice"
      examples = [
        "Should I invest in stocks?",
        "What's the best retirement plan?",
        "How should I allocate my 401k?"
      ]
      type = "DENY"
    }
    topics_config {
      name       = "medical-diagnosis"
      definition = "Providing medical diagnosis or treatment recommendations"
      examples = [
        "Do I have cancer?",
        "What medication should I take?",
        "How do I treat this condition?"
      ]
      type = "DENY"
    }
    topics_config {
      name       = "legal-advice"
      definition = "Providing specific legal advice or representation"
      examples = [
        "Should I sue someone?",
        "How do I file for bankruptcy?",
        "What are my legal rights?"
      ]
      type = "DENY"
    }
  }

  # Sensitive information filters
  sensitive_information_policy_config {
    pii_entities_config {
      action = "BLOCK"
      type   = "EMAIL"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "PHONE"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "US_SOCIAL_SECURITY_NUMBER"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "CREDIT_DEBIT_CARD_NUMBER"
    }
    pii_entities_config {
      action = "ANONYMIZE"
      type   = "NAME"
    }
    pii_entities_config {
      action = "ANONYMIZE"
      type   = "ADDRESS"
    }
  }

  # Word filters
  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
    words_config {
      text = "confidential"
    }
    words_config {
      text = "internal-only"
    }
  }

  tags = var.tags
}

# Create guardrail version
resource "aws_bedrock_guardrail_version" "v1" {
  count = var.enable_guardrails ? 1 : 0
  guardrail_arn = aws_bedrock_guardrail.content_filter[0].guardrail_arn
  description   = "Version 1"
}

