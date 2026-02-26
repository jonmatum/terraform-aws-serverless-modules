# CRUD API Examples Comparison

Two complete CRUD API implementations demonstrating different API Gateway approaches.

## Quick Comparison

| Example | API Type | Cost/Month | Latency | Best For |
|---------|----------|------------|---------|----------|
| **crud-api-http** | HTTP API (v2) | ~$65 | Lower | Most use cases ✅ |
| **crud-api-rest** | REST API (v1) | ~$85 | Higher | API keys, usage plans |

## Examples

### 1. crud-api-http (Recommended)

**Optimized** implementation using API Gateway HTTP API (v2).

```
API Gateway HTTP API → ALB → ECS → DynamoDB
```

**Advantages:**
- ✅ 71% cheaper API Gateway costs
- ✅ No NLB required (saves $16/month)
- ✅ Lower latency (one less hop)
- ✅ Simpler architecture
- ✅ Better CORS support

**Use when:**
- Building modern REST APIs
- Cost optimization matters
- Don't need API keys or usage plans

[View Example →](./crud-api-http/)

### 2. crud-api-rest

**Feature-rich** implementation using API Gateway REST API (v1).

```
API Gateway REST API → NLB → ALB → ECS → DynamoDB
```

**Advantages:**
- ✅ API keys and usage plans
- ✅ Request/response transformation
- ✅ Request validation
- ✅ SDK generation
- ✅ Caching

**Use when:**
- Need API keys for third-party access
- Need usage plans and throttling per key
- Need request transformation
- Building monetized API platform

[View Example →](./crud-api-rest/)

## Decision Tree

```
Do you need API keys or usage plans?
├─ Yes → Use crud-api-rest (REST API v1)
└─ No → Do you need request transformation?
    ├─ Yes → Use crud-api-rest (REST API v1)
    └─ No → Use crud-api-http (HTTP API v2) ✅
```

## Cost Breakdown

### HTTP API (crud-api-http)
- API Gateway: $1.00/million requests
- ALB: $16/month
- **Total Fixed: ~$65/month**

### REST API (crud-api-rest)
- API Gateway: $3.50/million requests
- NLB: $16/month
- ALB: $16/month
- **Total Fixed: ~$85/month**

**Savings with HTTP API: ~$20/month (~$240/year)**

## Architecture Comparison

### HTTP API (Optimized)
```
┌─────────┐     ┌─────────┐     ┌─────┐     ┌─────────┐
│ Client  │────▶│ API GW  │────▶│ ALB │────▶│   ECS   │
└─────────┘     │ HTTP v2 │     └─────┘     └─────────┘
                └─────────┘                       │
                                                  ▼
                                            ┌──────────┐
                                            │ DynamoDB │
                                            └──────────┘
```

### REST API (Feature Rich)
```
┌─────────┐     ┌─────────┐     ┌─────┐     ┌─────┐     ┌─────────┐
│ Client  │────▶│ API GW  │────▶│ NLB │────▶│ ALB │────▶│   ECS   │
└─────────┘     │ REST v1 │     └─────┘     └─────┘     └─────────┘
                └─────────┘                                   │
                                                              ▼
                                                        ┌──────────┐
                                                        │ DynamoDB │
                                                        └──────────┘
```

## Feature Matrix

| Feature | HTTP API | REST API |
|---------|----------|----------|
| Cost per million requests | $1.00 | $3.50 |
| NLB Required | ❌ No | ✅ Yes |
| Network Hops | 3 | 4 |
| API Keys | ❌ | ✅ |
| Usage Plans | ❌ | ✅ |
| Request Validation | Limited | Full |
| Request Transformation | ❌ | ✅ |
| Caching | ❌ | ✅ |
| SDK Generation | ❌ | ✅ |
| JWT Auth | ✅ | ✅ |
| Lambda Auth | ✅ | ✅ |
| CORS | ✅ Built-in | Manual |
| OpenAPI | ✅ | ✅ |
| WAF | ✅ | ✅ |
| X-Ray | ✅ | ✅ |

## Recommendation

**Start with HTTP API (crud-api-http)** unless you specifically need:
- API keys and usage plans
- Request/response transformation
- API Gateway caching
- SDK generation

Most modern applications don't need these features and benefit from:
- Lower costs (71% cheaper)
- Simpler architecture (no NLB)
- Better performance (lower latency)
- Easier CORS configuration

## Migration

Both examples use the same backend (FastAPI + DynamoDB), making migration straightforward:

### HTTP API → REST API
1. Add NLB resources
2. Update API Gateway module
3. Update VPC Link configuration

### REST API → HTTP API
1. Remove NLB resources
2. Update API Gateway module
3. Update VPC Link to use ALB directly

## Getting Started

```bash
# Try HTTP API (recommended)
cd crud-api-http
./deploy.sh

# Or try REST API
cd crud-api-rest
./deploy.sh
```

## Well-Architected Compliance

Both examples follow AWS Well-Architected Framework:
- ✅ Security: Encryption, IAM, VPC, WAF
- ✅ Reliability: Multi-AZ, auto-scaling, health checks
- ✅ Performance: Fargate, DynamoDB, CloudFront
- ✅ Operations: IaC, logging, monitoring, tracing

**HTTP API has better scores for:**
- Cost Optimization (71% cheaper)
- Sustainability (fewer resources)
- Operational Excellence (simpler)

## Learn More

- [HTTP API Example](./crud-api-http/)
- [REST API Example](./crud-api-rest/)
- [Detailed Comparison](./crud-api-http/COMPARISON.md)
- [Well-Architected Guide](../modules/api-gateway-v1/WELL_ARCHITECTED.md)
