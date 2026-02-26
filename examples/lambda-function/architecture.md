# Lambda Function Architecture

## Overview

This example demonstrates a containerized AWS Lambda function with Function URL for HTTP access. The architecture is serverless, cost-effective, and scales automatically.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                              │
│  ┌────────────┐                                             │
│  │   Client   │                                             │
│  └─────┬──────┘                                             │
│        │ HTTPS                                              │
│        ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Lambda Function URL                        │   │
│  │  (Public endpoint with CORS)                        │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                         │
│                    ▼                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Lambda Function (Container)                  │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  Python 3.11 Runtime                         │   │   │
│  │  │  - app.py (handler)                          │   │   │
│  │  │  - Environment variables                     │   │   │
│  │  │  - 512MB memory, 30s timeout                 │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                         │
│                    ▼                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         CloudWatch Logs                              │   │
│  │  - /aws/lambda/hello-lambda                         │   │
│  │  - 7-day retention                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         ECR Repository                               │   │
│  │  - Container image storage                          │   │
│  │  - Image scanning enabled                           │   │
│  │  - Lifecycle policy (keep last 10)                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Components

### Lambda Function
- **Runtime**: Container image (Python 3.11 base)
- **Memory**: 512MB (configurable 128MB-10GB)
- **Timeout**: 30 seconds (configurable 1s-15min)
- **Concurrency**: Unreserved (scales automatically)
- **Package Type**: Image (up to 10GB)

### Function URL
- **Type**: Public HTTPS endpoint
- **Authentication**: NONE (public access) or AWS_IAM
- **CORS**: Configurable origins, methods, headers
- **Protocol**: HTTPS only

### ECR Repository
- **Encryption**: AES256 at rest
- **Scanning**: Enabled on push
- **Lifecycle**: Keep last 10 images
- **Tag Mutability**: MUTABLE

### IAM Role
- **Service**: lambda.amazonaws.com
- **Policies**: 
  - AWSLambdaBasicExecutionRole (CloudWatch Logs)
  - AWSXRayDaemonWriteAccess (optional)

## Request Flow

```
1. Client Request
   │
   ├─→ HTTPS GET/POST to Function URL
   │
2. Lambda Invocation
   │
   ├─→ Cold start (if needed): Pull image from ECR
   ├─→ Warm start: Reuse existing container
   │
3. Handler Execution
   │
   ├─→ Parse event (HTTP method, path, headers, body)
   ├─→ Route to appropriate handler
   ├─→ Execute business logic
   │
4. Response
   │
   ├─→ Return JSON response with status code
   ├─→ Log to CloudWatch
   │
5. Client receives response
```

## Endpoints

### Default (`/`)
```bash
curl https://xxx.lambda-url.us-east-1.on.aws/

Response:
{
  "message": "Hello from containerized Lambda!",
  "method": "GET",
  "path": "/",
  "timestamp": "2024-01-15T10:30:00.123456"
}
```

### Health Check (`/health`)
```bash
curl https://xxx.lambda-url.us-east-1.on.aws/health

Response:
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.123456"
}
```

### Function Info (`/info`)
```bash
curl https://xxx.lambda-url.us-east-1.on.aws/info

Response:
{
  "function_name": "hello-lambda",
  "function_version": "$LATEST",
  "memory_limit": 512,
  "environment": "development",
  "log_level": "info",
  "request_id": "abc123..."
}
```

## Scaling Behavior

Lambda automatically scales based on incoming requests:

```
Concurrent Requests → Lambda Instances

1-10 requests    → 1-10 instances (instant)
10-100 requests  → 10-100 instances (instant)
100-1000 requests → 100-1000 instances (instant)

Default limits:
- Concurrent executions: 1000 (account-level)
- Burst: 500-3000 (region-dependent)
```

## Cold Start vs Warm Start

### Cold Start
- First invocation or after idle period
- Container image pulled from ECR
- Runtime initialized
- Handler loaded
- **Duration**: 1-3 seconds (container images)

### Warm Start
- Subsequent invocations within ~15 minutes
- Container reused
- Handler already loaded
- **Duration**: <100ms

### Optimization Strategies
1. Keep functions warm with scheduled invocations
2. Use smaller base images
3. Minimize dependencies
4. Use provisioned concurrency (additional cost)

## Monitoring

### CloudWatch Logs
- Log group: `/aws/lambda/hello-lambda`
- Retention: 7 days
- Contains: Function output, errors, request IDs

### CloudWatch Metrics (Automatic)
- **Invocations**: Number of times function is invoked
- **Duration**: Execution time in milliseconds
- **Errors**: Number of failed invocations
- **Throttles**: Number of throttled invocations
- **ConcurrentExecutions**: Number of concurrent executions
- **IteratorAge**: For stream-based invocations

### X-Ray Tracing (Optional)
Enable with `enable_xray = true`:
- End-to-end request tracing
- Service map visualization
- Performance bottleneck identification
- Error analysis

## Security

### IAM Execution Role
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

### Function URL Authentication

**Public Access (NONE)**:
- No authentication required
- Use for public APIs
- Implement application-level auth if needed

**IAM Authentication (AWS_IAM)**:
- Requires AWS Signature V4
- Use for private APIs
- Caller needs `lambda:InvokeFunctionUrl` permission

### Encryption
- **ECR**: AES256 encryption at rest
- **CloudWatch Logs**: Optional KMS encryption
- **Environment Variables**: Encrypted at rest with AWS managed keys

## Cost Breakdown

### Development Environment (~$0-5/month)

**Assumptions**:
- 10,000 requests/month
- 512MB memory
- 500ms average duration

**Costs**:
- Lambda requests: 10K × $0.20/1M = $0.002
- Lambda compute: 10K × 0.5s × 512MB = 2,560 GB-seconds
  - First 400,000 GB-seconds free
  - Cost: $0
- ECR storage: 0.5GB × $0.10 = $0.05
- CloudWatch Logs: 0.1GB × $0.50 = $0.05
- **Total: ~$0.10/month**

### Production Environment (~$19/month)

**Assumptions**:
- 100,000 requests/day = 3M/month
- 512MB memory
- 1s average duration

**Costs**:
- Lambda requests: 3M × $0.20/1M = $0.60
- Lambda compute: 3M × 1s × 512MB = 1,536,000 GB-seconds
  - After free tier: 1,136,000 × $0.0000166667 = $18.93
- ECR storage: 1GB × $0.10 = $0.10
- CloudWatch Logs: 5GB × $0.50 = $2.50
- **Total: ~$22/month**

### Cost Optimization Tips
1. **Right-size memory**: More memory = faster execution but higher cost
2. **Reduce duration**: Optimize code for faster execution
3. **Log retention**: Reduce from 7 days to 1 day for dev
4. **ECR lifecycle**: Keep fewer images (default: 10)
5. **Batch processing**: Process multiple items per invocation

## Deployment Flow

```
1. Developer runs ./deploy.sh
   │
2. Terraform applies infrastructure
   ├─→ Creates ECR repository
   ├─→ Creates IAM role
   ├─→ Creates Lambda function (placeholder image)
   ├─→ Creates Function URL
   ├─→ Creates CloudWatch log group
   │
3. Docker builds container image
   ├─→ Uses AWS Lambda Python 3.11 base
   ├─→ Installs dependencies
   ├─→ Copies application code
   │
4. Docker pushes to ECR
   ├─→ Authenticates with ECR
   ├─→ Tags image
   ├─→ Pushes to repository
   │
5. Lambda function updated
   ├─→ Updates function code with new image URI
   ├─→ Waits for update to complete
   │
6. Function ready to serve traffic
```

## Comparison: Lambda vs ECS

| Aspect | Lambda | ECS Fargate |
|--------|--------|-------------|
| **Scaling** | Automatic, instant | Automatic, ~1-2 min |
| **Cold Start** | 1-3s (containers) | N/A (always running) |
| **Max Duration** | 15 minutes | Unlimited |
| **Cost Model** | Pay per request | Pay per hour |
| **Idle Cost** | $0 | ~$15-30/month (min 1 task) |
| **Best For** | Event-driven, sporadic | Long-running, consistent |

## Well-Architected Framework

### Security
- IAM execution role with least privilege
- Encryption at rest (ECR, logs)
- Function URL with configurable auth
- No hardcoded secrets (use environment variables)

### Reliability
- Automatic scaling and fault tolerance
- CloudWatch Logs for debugging
- Retry behavior for async invocations
- Multi-AZ by default

### Performance
- Configurable memory (affects CPU)
- Container image caching
- Warm start optimization
- X-Ray tracing for bottlenecks

### Cost Optimization
- Pay-per-use pricing
- No idle costs
- Automatic scaling (no over-provisioning)
- Free tier: 1M requests + 400K GB-seconds/month

### Operational Excellence
- Infrastructure as Code (Terraform)
- Automated deployments
- CloudWatch Logs and metrics
- Version control with aliases

## Limitations

1. **Execution Time**: Maximum 15 minutes
2. **Memory**: Maximum 10GB
3. **Deployment Package**: Maximum 10GB (container image)
4. **Ephemeral Storage**: Maximum 10GB
5. **Concurrent Executions**: 1000 (default account limit)
6. **Cold Starts**: 1-3 seconds for container images

## When to Use Lambda

**Good Fit**:
- Event-driven workloads
- Sporadic or unpredictable traffic
- Short-lived tasks (<15 min)
- Microservices and APIs
- Scheduled jobs

**Not Ideal**:
- Long-running processes (>15 min)
- Consistent high traffic (ECS may be cheaper)
- Stateful applications
- Low-latency requirements (<100ms)
- WebSocket connections (use API Gateway WebSocket)
