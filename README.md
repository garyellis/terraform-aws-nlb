# tf_module_aws_nlb
Creates the following network load balancer configurations:

* Internal load balancer 
* External load balancer with optional eip allocations
* A list of one or more listeners
* A list of one or more target groups and health checks for target group types instance and ip
* Listener to elb and target group associations

> Target group to instance attachments are intentionally left outside of this module to allow loose coupling between target group to resource.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| eip\_allocation\_ids | A list of up to three EIP allocation IDs (one for each availability zone). | list | `<list>` | no |
| enable\_deletion\_protection | enable lb delete protection | string | `"false"` | no |
| internal | internal load balancer | string | n/a | yes |
| listeners | A list of elb listeners | list | `<list>` | no |
| listeners\_count | number of listeners in the listeners list variable | string | `"0"` | no |
| name | the resource name | string | n/a | yes |
| subnets | A  list of up to three subnet ids (one for each availability zone). | list | n/a | yes |
| tags | a map of tags | map | `<map>` | no |
| target\_group\_health\_checks | A list of target group health checks. The list index must match the corresponding target groups list index | list | `<list>` | no |
| target\_groups | A list of target group maps | list | `<list>` | no |
| target\_groups\_count | number of target groups in the target_groups list variable | string | `"0"` | no |
| vpc\_id | the nlb vpc id | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| lb\_arn |  |
| lb\_dns\_name |  |
| lb\_zone\_id |  |
| target\_group\_arns |  |


## Usage
```

```
