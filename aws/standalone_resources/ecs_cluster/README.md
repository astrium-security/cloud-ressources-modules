# AWS ECS Cluster Terraform Module

This Terraform module manages the creation of an Amazon ECS Cluster in AWS.

## Usage

```hcl
module "ecs_cluster" {
  source             = "git::https://github.com/syfrah-consulting/cloud-ressources-modules.git//aws/ecs_cluster"
  prefix             = "myproject"
  infra_environment  = "prod"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | The prefix to use for the ECS cluster | `string` | n/a | yes |
| infra_environment | The infrastructure environment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | The name of the ECS cluster |
| cluster_arn | The Amazon Resource Name (ARN) that identifies the ECS cluster |

## Authors

Module managed by [Syfrah Consulting](https://github.com/syfrah-consulting).

