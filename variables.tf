variable "enable_deletion_protection" {
  description = "enable lb delete protection"
  type = bool
  default = false
}

variable "eip_allocation_ids" {
  description = "A list of EIP allocation IDs (one per AZ)"
  type = list(string)
  default = []
}

variable "internal" {
  description = "flag to set as internal load balancer"
  type = bool
}

variable "listeners" {
  description = "A list of elb listeners"
  type = list(map(string))
  default = []
}

variable "listeners_count" {
  description = "number of listeners in the listeners list variable"
  type = number
  default = 0
}

variable "name" {
  description = "the resource name"
}

variable "subnets" {
  description = "A  list of up to three subnet ids (one for each availability zone)."
  type = list(string)
}

variable "tags" {
  description = "a map of tags"
  type = map(string)
  default = {}
}

variable "target_groups" {
  description = "A list of target group maps"
  type = any
  default = []
}

variable "target_groups_count" {
  description = "number of target groups in the target_groups list variable"
  type = number
  default = 0
}

variable "vpc_id" {
  description = "the nlb vpc id"
  type = string
}
