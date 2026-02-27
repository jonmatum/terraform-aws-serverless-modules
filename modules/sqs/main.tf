resource "aws_sqs_queue" "this" {
  name                       = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  fifo_queue                 = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size          = var.max_message_size
  delay_seconds             = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds

  # Dead letter queue
  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : var.dlq_arn != null ? jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # Encryption
  sqs_managed_sse_enabled = var.kms_master_key_id == null ? true : null
  kms_master_key_id       = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = var.tags
}

# Dead letter queue
resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                      = var.fifo_queue ? "${var.queue_name}-dlq.fifo" : "${var.queue_name}-dlq"
  fifo_queue                = var.fifo_queue
  message_retention_seconds = var.dlq_message_retention_seconds

  sqs_managed_sse_enabled = var.kms_master_key_id == null ? true : null
  kms_master_key_id       = var.kms_master_key_id

  tags = merge(var.tags, {
    Purpose = "DLQ"
  })
}

# Queue policy
resource "aws_sqs_queue_policy" "this" {
  count = var.queue_policy != null ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = var.queue_policy
}

# Redrive allow policy (for DLQ)
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}
