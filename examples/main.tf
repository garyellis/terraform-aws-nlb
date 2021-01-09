variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {}

variable "tags" {
  type = map(string)
  default = {}
}



module "lb_internal_tg_instance" {
  source = "../"

  enable_deletion_protection = false
  internal                   = true
  listeners_count            = 2
  listeners                  = local.listeners
  name                       = "lb-int-instance"
  subnets                    = var.private_subnets
  target_groups_count        = 2
  target_groups              = local.target_groups
  vpc_id                     = var.vpc_id
  tags                       = var.tags
}



module "lb_internal_tg_ip" {
  source = "../"

  enable_deletion_protection = false
  internal                   = true
  listeners_count            = 2
  listeners                  = local.listeners
  name                       = "lb-int-ip"
  subnets                    = var.private_subnets
  target_groups_count        = 2
  target_groups              = local.target_groups_ip
  vpc_id                     = var.vpc_id

  tags                       = var.tags

}

module "external_lb" {
  source = "../"

  enable_deletion_protection = false
  internal                   = false
  listeners_count            = 2
  listeners                  = local.listeners
  name                       = "lb-ext-instance"
  subnets                    = var.public_subnets
  target_groups_count        = "2"
  target_groups              = local.target_groups
  vpc_id                     = var.vpc_id
  
  tags                       = var.tags
}


module "external_lb_eip_allocations" {
  source = "../"

  eip_allocation_ids         = aws_eip.external_lb_eip_allocations.*.allocation_id
  enable_deletion_protection = false
  internal                   = false
  listeners_count            = 2
  listeners                  = local.listeners
  name                       = "lb-ext-eip"
  subnets                    = var.public_subnets
  target_groups_count        = 2
  target_groups              = local.target_groups
  vpc_id                     = var.vpc_id
  tags                       = var.tags
}

resource "aws_eip" "external_lb_eip_allocations" {
  count = length(var.public_subnets)

  tags     = var.tags
  vpc      = true
}


locals {
  listeners                  = [
    { port = "443", target_group_index = "0" },
    { port = "6443", target_group_index = "1" },
  ]
  listeners_count            = 2
  target_groups              = [
    { name = "https",     target_type = "instance", port = "443",  proxy_protocol_v2 = "false", deregistration_delay = "5", health_check = local.target_group_health_checks[0]},
    { name = "apiserver", target_type = "instance", port = "6443", proxy_protocol_v2 = "false", health_check = local.target_group_health_checks[1] },
  ]
  target_groups_ip           = [
    { name = "httpsip",     target_type = "ip", port = "443",  proxy_protocol_v2 = "false", health_check = local.target_group_health_checks[0] },
    { name = "apiserverip", target_type = "ip", port = "6443", proxy_protocol_v2 = "false", health_check = local.target_group_health_checks[1]},
  ]

  target_group_health_checks = [
    { protocol = "HTTPS", path = "/healthz", port = "traffic-port",  interval = "10", healthy_threshold = "2", unhealthy_threshold = "2" },
    { protocol = "HTTPS", path = "/healthz", port = "traffic-port", interval = "10", healthy_threshold = "2", unhealthy_threshold = "2" },
  ]

  target_groups_count        = 2
}
