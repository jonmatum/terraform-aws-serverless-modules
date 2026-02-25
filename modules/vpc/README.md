# Terraform AWS VPC Module

VPC module with public and private subnets, NAT gateway, and routing.

## Usage

```hcl
module "vpc" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/vpc?ref=modules/vpc/v0.1.0"

  name               = "my-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}
```
