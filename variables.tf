variable "enable_deletion_protection" {
  description = "enable lb delete protection"
  default = "false"
}

variable "internal" {
  description = "internal load balancer"
}

variable "listeners" {
  default = []
}

variable "listeners_count" {
  default = "0"
}

variable "name" {
  description = "the resource name"
}

variable "subnets" {
  description = "the target subnets"
  type = "list"
}

variable "tags" {
  description = "a map of tags"
  type = "map"
  default = {}
}

variable "target_groups" {
   default = []
}

variable "target_groups_count" {
  default = "0"
}

variable "target_group_health_checks" {
  default = []
}
variable "target_group_attachments" {
  description = "target group instance id attachments"
  type = "list"
  default = []
}

variable "vpc_id" {
  description = "the target vpc id"
}
