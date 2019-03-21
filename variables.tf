variable "enable_deletion_protection" {
  description = "enable lb delete protection"
  default = "false"
}

variable "eip_allocation_ids" {
  description = "A list of up to three EIP allocation IDs (one for each availability zone)."
  type = "list"
  default = []
}

variable "internal" {
  description = "internal load balancer"
}

variable "listeners" {
  description = "A list of elb listeners"
  default = []
}

variable "listeners_count" {
  description = "number of listeners in the listeners list variable"
  default = "0"
}

variable "name" {
  description = "the resource name"
}

variable "subnets" {
  description = "A  list of up to three subnet ids (one for each availability zone)."
  type = "list"
}

variable "tags" {
  description = "a map of tags"
  type = "map"
  default = {}
}

variable "target_groups" {
  description = "A list of target group maps"
  default = []
}

variable "target_groups_count" {
  description = "number of target groups in the target_groups list variable"
  default = "0"
}

variable "target_group_health_checks" {
  description = "A list of target group health checks. The list index must match the corresponding target groups list index"
  default = []
}

variable "vpc_id" {
  description = "the nlb vpc id"
}
