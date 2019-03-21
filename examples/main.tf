variable "public_subnets" {
  type = "list"
}

variable "private_subnets" {
  type = "list"
}

variable "vpc_id" {}

variable "tags" {
  type = "map"
  default = {}
}



module "lb_internal_tg_instance" {
  source = "../"

  enable_deletion_protection = "0"
  internal                   = "true"
  listeners_count            = "2"
  listeners                  = ["${local.listeners}"]
  name                       = "lb-int-instance"
  subnets                    = ["${var.private_subnets}"]
  target_groups_count        = "2"
  target_groups              = ["${local.target_groups}"]
  target_group_health_checks = ["${local.target_group_health_checks}"]
  vpc_id                     = "${var.vpc_id}"

  tags                       = "${var.tags}"

}



#module "lb_internal_tg_ip" {
#  source = "../"
#
#  enable_deletion_protection = "0"
#  internal                   = "true"
#  listeners_count            = "2"
#  listeners                  = ["${local.listeners}"]
#  name                       = "lb-int-ip"
#  subnets                    = ["${var.private_subnets}"]
#  target_groups_count        = "2"
#  target_groups              = ["${local.target_groups_ip}"]
#  target_group_health_checks = ["${local.target_group_health_checks}"]
#  vpc_id                     = "${var.vpc_id}"
#
#  tags                       = "${var.tags}"
#
#}

module "external_lb" {
  source = "../"

  enable_deletion_protection = "0"
  internal                   = "false"
  listeners_count            = "2"
  listeners                  = ["${local.listeners}"]
  name                       = "lb-ext-instance"
  subnets                    = ["${var.public_subnets}"]
  target_groups_count        = "2"
  target_groups              = ["${local.target_groups}"]
  target_group_health_checks = ["${local.target_group_health_checks}"]
  vpc_id                     = "${var.vpc_id}"
  
  tags                       = "${var.tags}"
}


module "external_lb_eip_allocations" {
  source = "../"

  eip_allocation_ids         = ["${aws_eip.external_lb_eip_allocations.*.id}"]
  enable_deletion_protection = "0"
  internal                   = "false"
  listeners_count            = "2"
  listeners                  = ["${local.listeners}"]
  name                       = "lb-ext-eip"
  subnets                    = ["${var.public_subnets}"]
  target_groups_count        = "2"
  target_groups              = ["${local.target_groups}"]
  target_group_health_checks = ["${local.target_group_health_checks}"]
  vpc_id                     = "${var.vpc_id}"

  tags                       = "${var.tags}"
}

resource "aws_eip" "external_lb_eip_allocations" {
  count = "${length(var.public_subnets)}"

  tags = "${var.tags}"
  vpc      = true
}




locals {
  listeners                  = [
    { port = "443", target_group_index = "0" },
    { port = "6443", target_group_index = "1" },
  ]
  listeners_count            = "2"
  target_groups              = [
    { name = "https",     target_type = "instance", port = "443",  proxy_protocol_v2 = "false" },
    { name = "apiserver", target_type = "instance", port = "6443", proxy_protocol_v2 = "false" },
  ]
  target_groups_ip     = [
    { name = "httpsip",     target_type = "ip", port = "443",  proxy_protocol_v2 = "false" },
    { name = "apiserverip", target_type = "ip", port = "6443", proxy_protocol_v2 = "false" },
  ]

  target_group_health_checks = [
    { target_groups_index = "0", protocol = "HTTPS", path = "/healthz", port = "443",  interval = "10", healthy_threshold = "2", unhealthy_threshold = "2" },
    { target_groups_index = "1", protocol = "HTTPS", path = "/healthz", port = "6443", interval = "10", healthy_threshold = "2", unhealthy_threshold = "2" },
  ]
  target_groups_count        = "2"
}
