# HTTP API vs REST API Comparison

## Architecture Comparison

### HTTP API (v2) - Optimized
```
API Gateway HTTP API → VPC Link → ALB → ECS → DynamoDB
```
- **3 network hops**
- **No NLB required**
- **Direct ALB integration**

### REST API (v1) - Feature Rich
```
API Gateway REST API → VPC Link → NLB → ALB → ECS → DynamoDB
```
- **4 network hops**
- **NLB required** (AWS limitation)
- **Indirect ALB integration**

## Cost Comparison (Monthly)

| Component | HTTP API | REST API | Difference |
|-----------|----------|----------|------------|
| API Gateway | $1.00/M requests | $3.50/M requests | -71% |
| NLB | $0 | $16.20 | -$16.20 |
| ALB | $16.20 | $16.20 | $0 |
| **Total Fixed** | **$16.20** | **$32.40** | **-$16.20** |

**Annual Savings**: ~$194

## Performance Comparison

| Metric | HTTP API | REST API |
|--------|----------|----------|
| Network Hops | 3 | 4 |
| Added Latency | Baseline | +1-3ms (NLB) |
| Throughput | High | High |
| Cold Start | Same | Same |

## Feature Comparison

| Feature | HTTP API (v2) | REST API (v1) |
|---------|---------------|---------------|
| **Pricing** | | |
| Per million requests | $1.00 | $3.50 |
| **Integration** | | |
| ALB Direct | ✅ Yes | ❌ No (needs NLB) |
| Lambda | ✅ Yes | ✅ Yes |
| HTTP Endpoints | ✅ Yes | ✅ Yes |
| **Authentication** | | |
| JWT Authorizers | ✅ Yes | ✅ Yes |
| Lambda Authorizers | ✅ Yes | ✅ Yes |
| IAM | ✅ Yes | ✅ Yes |
| API Keys | ❌ No | ✅ Yes |
| **API Management** | | |
| Usage Plans | ❌ No | ✅ Yes |
| Throttling | ✅ Yes | ✅ Yes |
| Caching | ❌ No | ✅ Yes |
| **Request/Response** | | |
| Request Validation | ⚠️ Limited | ✅ Full |
| Request Transformation | ❌ No | ✅ Yes |
| Response Transformation | ❌ No | ✅ Yes |
| **Developer Experience** | | |
| OpenAPI Support | ✅ Yes | ✅ Yes |
| CORS | ✅ Built-in | ⚠️ Manual |
| SDK Generation | ❌ No | ✅ Yes |
| **Monitoring** | | |
| CloudWatch Logs | ✅ Yes | ✅ Yes |
| CloudWatch Metrics | ✅ Yes | ✅ Yes |
| X-Ray Tracing | ✅ Yes | ✅ Yes |
| **Security** | | |
| WAF | ✅ Yes | ✅ Yes |
| Resource Policies | ✅ Yes | ✅ Yes |
| Private APIs | ✅ Yes | ✅ Yes |

## Use Case Recommendations

### Choose HTTP API (v2) when:

✅ **Cost is a priority**
- Startups and small projects
- High-volume APIs (71% cheaper per request)
- Budget-conscious deployments

✅ **Simple proxy use case**
- Forwarding to ALB/Lambda
- No complex transformations needed
- Modern REST API patterns

✅ **Performance matters**
- Lower latency requirements
- Simpler architecture preferred
- Fewer network hops

✅ **Modern authentication**
- JWT tokens (Cognito, Auth0, etc.)
- OAuth 2.0 flows
- No need for API keys

### Choose REST API (v1) when:

✅ **Need API keys and usage plans**
- Third-party API monetization
- Per-customer rate limiting
- Usage tracking and billing

✅ **Need request/response transformation**
- Legacy system integration
- Protocol translation
- Complex mapping templates

✅ **Need request validation**
- Strict input validation
- Schema enforcement at gateway
- Reduce backend validation load

✅ **Need SDK generation**
- Client library distribution
- Multi-language support
- Automated client code

✅ **Need caching**
- Reduce backend load
- Improve response times
- Lower costs for repeated requests

## Migration Path

### From REST API to HTTP API

1. **Assess feature usage**
   - Check if using API keys → Consider alternatives
   - Check if using request transformation → Move to backend
   - Check if using caching → Use CloudFront or backend cache

2. **Update infrastructure**
   ```hcl
   # Change module
   module "api_gateway" {
     source = "../../modules/api-gateway"  # HTTP API
     # Remove NLB resources
     # Update integrations to use ALB directly
   }
   ```

3. **Test thoroughly**
   - Verify all endpoints work
   - Check authentication flows
   - Load test performance

4. **Deploy**
   - Blue/green deployment recommended
   - Update DNS gradually
   - Monitor metrics closely

### From HTTP API to REST API

1. **Add NLB**
   ```hcl
   module "api_gateway_rest" {
     source = "../../modules/api-gateway-v1"
     # Add NLB configuration
     # Update VPC Link to use NLB
   }
   ```

2. **Update integrations**
   - Change from ALB to NLB
   - Add request validation if needed
   - Configure API keys if needed

3. **Deploy and test**

## Real-World Examples

### HTTP API Use Cases
- Mobile app backends
- Microservices APIs
- Serverless applications
- Internal APIs
- Modern SaaS products

### REST API Use Cases
- Public API platforms (Stripe, Twilio style)
- Legacy system integrations
- APIs requiring strict validation
- Monetized API products
- Enterprise APIs with complex requirements

## Recommendation

**Start with HTTP API (v2)** for most projects. It's:
- Cheaper (71% less per request)
- Simpler (no NLB needed)
- Faster (lower latency)
- Modern (better CORS, JWT support)

**Migrate to REST API (v1)** only when you need:
- API keys and usage plans
- Request/response transformation
- Caching at API Gateway level
- SDK generation

## Well-Architected Alignment

| Pillar | HTTP API | REST API |
|--------|----------|----------|
| Operational Excellence | ✅ Simpler | ⚠️ More complex |
| Security | ✅ Equal | ✅ Equal |
| Reliability | ✅ Fewer components | ⚠️ More components |
| Performance | ✅ Lower latency | ⚠️ Higher latency |
| Cost Optimization | ✅ 71% cheaper | ❌ More expensive |
| Sustainability | ✅ Fewer resources | ⚠️ More resources |

**Winner**: HTTP API (v2) for most use cases
