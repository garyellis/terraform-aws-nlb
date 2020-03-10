resource "aws_lb" "lb" {
  count = length(var.subnets) > 0 ? 1 : 0

  name                             = var.name
  enable_cross_zone_load_balancing = length(var.subnets) > 1 ? true : false
  internal                         = var.internal
  load_balancer_type               = "network"
  enable_deletion_protection       = var.enable_deletion_protection

  dynamic "subnet_mapping" {
    iterator = subnet_id
    for_each = var.subnets
    content {
      subnet_id = subnet_id.value
      allocation_id = element(concat(var.eip_allocation_ids, list("")), count.index)
    }
  }

  tags  = merge(map("Name", var.name), var.tags)

  lifecycle {
    ignore_changes = ["subnet_mapping"]
  }
}

resource "aws_lb_listener" "listener" {
  count = var.listeners_count

  protocol              = "TCP"
  port                  = lookup(var.listeners[count.index], "port")
  load_balancer_arn     = join("",aws_lb.lb.*.arn)
  default_action {
      target_group_arn = aws_lb_target_group.target_group[lookup(var.listeners[count.index], "target_group_index")].arn
      type = "forward"
  }
}

resource "aws_lb_target_group" "target_group" {
  count = var.target_groups_count

  name                  = format("%s-%s", var.name, lookup(var.target_groups[count.index], "name"))
  port                  = lookup(var.target_groups[count.index], "port")
  proxy_protocol_v2     = lookup(var.target_groups[count.index], "proxy_protocol_v2", false)
  protocol              = "TCP"
  target_type           = lookup(var.target_groups[count.index], "target_type", "instance")
  deregistration_delay  = lookup(var.target_groups[count.index], "deregistration_delay", 60)
  vpc_id                = var.vpc_id

  dynamic "health_check" {
    for_each = var.target_group_health_checks
    iterator = target_group_health_checks
    content {
      healthy_threshold   = lookup(target_group_health_checks.value, "healthy_threshold")
      unhealthy_threshold = lookup(target_group_health_checks.value, "unhealthy_threshold")
      interval            = lookup(target_group_health_checks.value, "interval")
      path                = lookup(target_group_health_checks.value, "path", null)
      matcher             = lookup(target_group_health_checks.value, "matcher", null)
      protocol            = lookup(target_group_health_checks.value, "protocol")
    }
  }


  tags                  = merge(map("Name", format("%s-%s", var.name, lookup(var.target_groups[count.index], "name"))), var.tags)
}
