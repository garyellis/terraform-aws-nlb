# tf_module_aws_nlb
Creates the following network load balancer configurations:

* Internal load balancer in one or more AZs
* External load balancer in one or more AZs with optional eip allocations
* A list of one or more listeners
* A list of one or more target groups and health checks. Target group type instance and ip are both configurable.
* Listener to elb and listener to target group associations

> Target group to instance attachments are left out of this module on purpose to ensure loose coupling between target group and back end instances.


## Terraform version

* v0.12

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| eip\_allocation\_ids | A list of EIP allocation IDs (one per AZ) | `list(string)` | `[]` | no |
| enable\_deletion\_protection | enable lb delete protection | `bool` | `false` | no |
| internal | internal load balancer | `bool` | n/a | yes |
| listeners | A list of elb listeners | `list(string)` | `[]` | no |
| listeners\_count | number of listeners in the listeners list variable | `number` | `0` | no |
| name | the resources name | `string` | n/a | yes |
| subnets | A  list of subnet ids (one per AZ) | `list(string)` | n/a | yes |
| tags | a map of tags | `map(string)` | `{}` | no |
| target\_group\_health\_checks | A list of target group health checks. The list index must match the corresponding target groups list index | `list(string)` | `[]` | no |
| target\_groups | A list of target group maps | `list(map(string))` | `[]` | no |
| target\_groups\_count | number of target groups in the target_groups list variable | `number` | `0` | no |
| vpc\_id | the nlb vpc id | `string` | n/a | yes |

## Outputs

| Name | Description | Type
|------|-------------|:----:|
| lb\_arn |  the load balancer arn| `string`
| lb\_dns\_name |  the load balancer dns name | `string`
| lb\_zone\_id |  the load balancer | `string`
| target\_group\_arns | the canonical hosted zone ID of the lb (for use with route53 alias recordss| `list(string)`


## Usage
```

```
