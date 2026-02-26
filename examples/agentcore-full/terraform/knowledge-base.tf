# S3 bucket for Knowledge Base documents
resource "aws_s3_bucket" "kb_docs" {
  bucket = "${var.project_name}-kb-docs-${local.account_id}"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "kb_docs" {
  bucket = aws_s3_bucket.kb_docs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kb_docs" {
  bucket = aws_s3_bucket.kb_docs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# OpenSearch Serverless Collection for Knowledge Base
resource "aws_opensearchserverless_security_policy" "kb_encryption" {
  name = "${var.project_name}-kb-encryption"
  type = "encryption"
  policy = jsonencode({
    Rules = [{
      ResourceType = "collection"
      Resource     = ["collection/${var.project_name}-kb"]
    }]
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "kb_network" {
  name = "${var.project_name}-kb-network"
  type = "network"
  policy = jsonencode([{
    Rules = [{
      ResourceType = "collection"
      Resource     = ["collection/${var.project_name}-kb"]
    }]
    AllowFromPublic = true
  }])
}

resource "aws_opensearchserverless_collection" "kb" {
  name = "${var.project_name}-kb"
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.kb_encryption,
    aws_opensearchserverless_security_policy.kb_network
  ]

  tags = var.tags
}

resource "aws_opensearchserverless_access_policy" "kb" {
  name = "${var.project_name}-kb-access"
  type = "data"
  policy = jsonencode([{
    Rules = [{
      ResourceType = "collection"
      Resource     = ["collection/${var.project_name}-kb"]
      Permission = [
        "aoss:CreateCollectionItems",
        "aoss:UpdateCollectionItems",
        "aoss:DescribeCollectionItems"
      ]
    }, {
      ResourceType = "index"
      Resource     = ["index/${var.project_name}-kb/*"]
      Permission = [
        "aoss:CreateIndex",
        "aoss:DescribeIndex",
        "aoss:ReadDocument",
        "aoss:WriteDocument",
        "aoss:UpdateIndex",
        "aoss:DeleteIndex"
      ]
    }]
    Principal = [aws_iam_role.kb.arn]
  }])
}

# Knowledge Base
resource "aws_bedrockagent_knowledge_base" "docs" {
  name     = "${var.project_name}-kb"
  role_arn = aws_iam_role.kb.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v1"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.kb.arn
      vector_index_name = "bedrock-knowledge-base-index"
      field_mapping {
        vector_field   = "embedding"
        text_field     = "text"
        metadata_field = "metadata"
      }
    }
  }

  depends_on = [aws_opensearchserverless_access_policy.kb]

  tags = var.tags
}

# Data Source for Knowledge Base
resource "aws_bedrockagent_data_source" "s3" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.docs.id
  name              = "s3-documents"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.kb_docs.arn
    }
  }
}
