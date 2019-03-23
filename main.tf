# we manage multiple aws_lb resources here to handle a variable number of input subnets (up to three) for the subnet_mapping block.
# Note - In terraform v0.12, we will be able to leverage dynamic block for loops to simplify/consolidate down to one aws_lb resource.
# https://www.terraform.io/docs/configuration/expressions.html#dynamic-blocks
resource "aws_lb" "lb_1az" {
  count = "${length(var.subnets) == 1 ? 1 : 0}"

  name = "${var.name}"
  enable_cross_zone_load_balancing = "${length(var.subnets) > 1 ? "true" : "false"}"
  internal                         = "${var.internal}"
  load_balancer_type               = "network"
  enable_deletion_protection       = "${var.enable_deletion_protection}"

  subnet_mapping {
    subnet_id     = "${var.subnets[0]}"
    allocation_id = "${element(concat(var.eip_allocation_ids, list("")),0)}"
  }

  tags                             = "${merge(map("Name", var.name), var.tags)}"


  # Subnet mapping values are not populated and persisted into state file when allocation id is empty. This will cause elb recreation on subsequent plan/applys.
  # We work around this bug by ignoring lifecycle changes on subnet_mappings.
  # As of 3/2019 a PR in terraform-provider-aws is open awaiting approval.
  # We can remove the lifecycle block once the PR is merged and release is created that includes the fix.
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7397
  # https://github.com/terraform-providers/terraform-provider-aws/pull/7434

  lifecycle {
    ignore_changes = ["subnet_mapping"]
  }
}

resource "aws_lb" "lb_2az" {
  count = "${length(var.subnets) == 2 ? 1 : 0}"

  name = "${var.name}"
  enable_cross_zone_load_balancing = "${length(var.subnets) > 1 ? "true" : "false"}"
  internal                         = "${var.internal}"
  load_balancer_type               = "network"
  enable_deletion_protection       = "${var.enable_deletion_protection}"

  subnet_mapping {
    subnet_id     = "${var.subnets[0]}"
    allocation_id = "${element(concat(var.eip_allocation_ids, list("")),0)}"
  }

  subnet_mapping {
    subnet_id     = "${var.subnets[1]}"
    allocation_id = "${element(concat(var.eip_allocation_ids, list("")),1)}"
  }

  tags                             = "${merge(map("Name", var.name), var.tags)}"

  lifecycle {
    ignore_changes = ["subnet_mapping"]
  }
}

resource "aws_lb" "lb_3az" {
  count = "${length(var.subnets) == 3 ? 1 : 0}"

  name                             = "${var.name}"
  enable_cross_zone_load_balancing = "${length(var.subnets) > 1 ? "true" : "false"}"
  internal                         = "${var.internal}"
  load_balancer_type               = "network"
  enable_deletion_protection       = "${var.enable_deletion_protection}"

  subnet_mapping {
    subnet_id     = "${var.subnets[0]}"
    allocation_id = "${element(concat(var.eip_allocation_ids, list("")),0)}"
  }

  subnet_mapping {
    subnet_id     = "${var.subnets[1]}"
    allocation_id = "${element(concat(var.eip_allocation_ids, list("")),1)}"
  }

  subnet_mapping {
    subnet_id     = "${var.subnets[2]}"
    allocation_id = "${element(concat(var.eip_allocation_ids, list("")),2)}"
  }

  tags                             = "${merge(map("Name", var.name), var.tags)}"

  lifecycle {
    ignore_changes = ["subnet_mapping"]
  }
}


locals {
  lb_arn      = "${join("", aws_lb.lb_1az.*.arn, aws_lb.lb_2az.*.arn, aws_lb.lb_3az.*.arn)}"
  lb_dns_name = "${join("", aws_lb.lb_1az.*.dns_name, aws_lb.lb_2az.*.dns_name, aws_lb.lb_3az.*.dns_name)}"
  lb_zone_id  = "${join("", aws_lb.lb_1az.*.zone_id, aws_lb.lb_2az.*.zone_id, aws_lb.lb_3az.*.zone_id)}"
}


resource "aws_lb_listener" "listener" {
  count = "${var.listeners_count}"

  protocol              = "TCP"
  port                  = "${lookup(var.listeners[count.index], "port")}"
  load_balancer_arn     = "${local.lb_arn}"

  default_action {
    target_group_arn    = "${aws_lb_target_group.target_group.*.arn[lookup(var.listeners[count.index], "target_group_index", 0)]}"
    type = "forward"
  }
}

resource "aws_lb_target_group" "target_group" {
  count = "${var.target_groups_count}"

  name                  = "${format("%s-%s", var.name, lookup(var.target_groups[count.index], "name"))}"
  port                  = "${lookup(var.target_groups[count.index], "port")}"
  proxy_protocol_v2     = "${lookup(var.target_groups[count.index], "proxy_protocol_v2", false)}"
  protocol              = "TCP"
  target_type           = "${lookup(var.target_groups[count.index], "target_type", "instance")}"
  deregistration_delay  = "${lookup(var.target_groups[count.index], "deregistration_delay", 60)}"
  vpc_id                = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "${lookup(var.target_group_health_checks[count.index], "healthy_threshold")}"
    unhealthy_threshold = "${lookup(var.target_group_health_checks[count.index], "unhealthy_threshold")}"
    interval            = "${lookup(var.target_group_health_checks[count.index], "interval")}"
    path                = "${lookup(var.target_group_health_checks[count.index], "path")}"
    protocol            = "${lookup(var.target_group_health_checks[count.index], "protocol")}"
  }
  tags                  = "${merge(map("Name", format("%s-%s", var.name, lookup(var.target_groups[count.index], "name"))), var.tags)}"
}
