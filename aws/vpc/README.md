# AWS VPC Module

This is a Terraform module for creating a VPC on AWS with public and private subnets. This module uses the standalone VPC module for creating the VPC and then adds public and private subnets to it.

## Usage

Here is an example of how you can use this module in your own Terraform configuration:

```hcl
module "vpc" {
  source              = "git::https://github.com/syfrah-consulting/cloud-ressources-modules.git//aws/vpc"
  cidr                = "10.0.0.0/16"
  prefix              = "myproject"
  infra_environment   = "prod"
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones  = ["us-west-2a", "us-west-2b"]
}
```

Replace the variables with your own values.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Prefix to use for all resources | `string` | n/a | yes |
| infra_environment | The infrastructure environment | `string` | n/a | yes |
| cidr | The CIDR block for the VPC | `string` | n/a | yes |
| public_subnets | A list of public subnet CIDR blocks | `list(string)` | `[]` | no |
| private_subnets | A list of private subnet CIDR blocks | `list(string)` | `[]` | no |
| availability_zones | A list of Availability Zones in the Region | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| public_subnets | IDs of the public subnets |
| private_subnets | IDs of the private subnets |
| internet_gateway | The ID of the internet gateway |
| public_route_table | The ID of the public route table |

## Requirements

- Terraform v0.14.7 or later
- AWS Provider v3.37.0 or later

## Authors

Module managed by [Syfrah Consulting](https://github.com/syfrah-consulting)
