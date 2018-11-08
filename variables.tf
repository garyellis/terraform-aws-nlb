variable "enable_deletion_protection" {
  description = "enable lb delete protection"
  default = "false"
}

variable "internal" {
  description = "is an internal elb. False for internet facing lb"
  default = "true"
}

variable "lb_listener_port" {
  description = "The load balancer listener port"
  default = 443
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

variable "target_group_attachments" {
  description = "target group instance id attachments"
  type = "list"
  default = []
}

variable "target_group_port" {
  description = "target group instances port"
  default = "443"
}

variable "target_group_type" {
  description = "the target group type. supported types are instance and ip"
  default     = "instance"
}

variable "vpc_id" {
  description = "the target vpc id"
}
