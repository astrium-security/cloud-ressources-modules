# AWS ECS Service Module

This Terraform module creates an ECS service on AWS.

## Usage

```hcl
module "ecs_service" {
  source = "git::https://github.com/syfrah-consulting/cloud-ressources-modules.git//aws/ecs_service?ref=main"
  
  prefix               = "your-prefix"
  container_name       = "your-container-name"
  app_environment      = "your-app-environment"
  cluster_id           = "your-cluster-id"
  task_definition_arn  = "your-task-definition-arn"
  desired_count        = 2
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  force_new_deployment = true
  security_groups      = ["sg-abc123"]
  public_subnet        = ["subnet-abc123"]
  target_group_arn     = "your-target-group-arn"
  container_port       = 8080
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | The prefix to use for all resources | `string` | n/a | yes |
| container_name | The name of the container | `string` | n/a | yes |
| app_environment | The application environment | `string` | n/a | yes |
| cluster_id | The ID of the ECS cluster | `string` | n/a | yes |
| task_definition_arn | The ARN of the task definition | `string` | n/a | yes |
| desired_count | The desired number of instances of the task definition to keep running on the service | `number` | n/a | yes |
| launch_type | The launch type on which to run your service | `string` | `"EC2"` | no |
| scheduling_strategy | The scheduling strategy to use for the service | `string` | `"REPLICA"` | no |
| force_new_deployment | Forces a new deployment of the service | `bool` | `false` | no |
| security_groups | The list of security group IDs for the service | `list(string)` | n/a | yes |
| public_subnet | List of public subnets | `list(string)` | n/a | yes |
| target_group_arn | The ARN of the load balancer target group | `string` | n/a | yes |
| container_port | The port on which the container is listening | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs_service_arn | The ARN of the ECS service |
