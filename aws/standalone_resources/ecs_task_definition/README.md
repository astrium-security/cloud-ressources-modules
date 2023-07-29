# AWS ECS Task Definition Module

This module creates an Amazon ECS task definition along with the necessary IAM roles and a CloudWatch log group.

## Usage

Example usage:

```hcl
module "ecs_task_definition" {
  source                   = "git::https://github.com/syfrah-consulting/cloud-ressources-modules.git//aws/ecs-task-definition"
  prefix                   = "my-prefix"
  container_name           = "my-container"
  app_environment          = "dev"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_port           = 80
  host_port                = 80
  region                   = "us-east-1"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| prefix | The prefix to use for all resources | string | n/a | yes |
| container_name | The name of the container | string | n/a | yes |
| app_environment | The application environment | string | n/a | yes |
| network_mode | The network mode for the task | string | `"awsvpc"` | no |
| requires_compatibilities | The launch type required by the task | list(string) | `["FARGATE"]` | no |
| cpu | The amount of CPU used by the task | string | n/a | yes |
| memory | The amount of memory used by the task | string | n/a | yes |
| container_port | The port on the container to associate with the load balancer | number | n/a | yes |
| host_port | The port on the instance to associate with the load balancer | number | n/a | yes |
| region | The region in which to create the resources | string | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| main_app_task_definition_arn | The ARN of the main app ECS task definition |
| ecs_task_execution_role_arn | The ARN of the ECS task execution role |
| ecs_task_role_arn | The ARN of the ECS task role |
| log_group_name | The name of the CloudWatch log group |


