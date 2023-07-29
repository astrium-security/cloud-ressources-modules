# Standalone VPC Module

This module creates a standalone VPC.

## Inputs

| Name | Description | Type |
|--|--|--|
| prefix | Prefix to use for all resources | `string` |
| infra_environment | The infrastructure environment | `string` |
| cidr | The CIDR block for the VPC | `string` |

## Outputs

| Name | Description |
|--|--|
| vpc_id | The ID of the VPC |
