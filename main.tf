resource "aws_lb" "lb" {
  name = "${var.name}"
  enable_cross_zone_load_balancing = "${length(var.subnets) > 1 ? "true" : "false"}"
  internal = "${var.internal}"
  load_balancer_type = "network"
  enable_deletion_protection = "${var.enable_deletion_protection}"
  subnets = ["${var.subnets}"]
	tags = "${merge(map("Name", var.name), var.tags)}"
}

resource "aws_lb_listener" "listener" {
  count = "${var.listeners_count}"

  protocol = "TCP"
  port = "${lookup(var.listeners[count.index], "port")}"
  load_balancer_arn = "${aws_lb.lb.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.*.arn[lookup(var.listeners[count.index], "target_group_index", 0)]}"
    type = "forward"
  }
}

resource "aws_lb_target_group" "target_group" {
  count = "${var.target_groups_count}"

  name                  = "${format("%s-%s", var.name, lookup(var.target_groups[count.index], "name"))}"
  port                  = "${lookup(var.target_groups[count.index], "port")}"
  proxy_protocol_v2     = "${lookup(var.target_groups[count.index], "proxy_protocol_v2")}"
  protocol              = "TCP"
  target_type           = "${lookup(var.target_groups[count.index], "target_type")}"
  vpc_id                = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "${lookup(var.target_group_health_checks[count.index], "healthy_threshold")}"
    unhealthy_threshold = "${lookup(var.target_group_health_checks[count.index], "unhealthy_threshold")}"
    interval            = "${lookup(var.target_group_health_checks[count.index], "interval")}"
    path                = "${lookup(var.target_group_health_checks[count.index], "path")}"
    protocol            = "${lookup(var.target_group_health_checks[count.index], "protocol")}"
  }
  tags                  = "${merge(map("Name", format("%s-%s", lookup(var.target_groups[count.index], "name"), lookup(var.target_groups[count.index], "port"))), var.tags)}"
}

#resource "aws_lb_target_group_attachment" "attachments" {
#  count = "${target_group_attachments_count)}"
#
#  target_group_arn = "${element(aws_lb_target_group.target_group.*.arn, lookup(var.target_group_attachments[count.index] "target_group_index"))}"
#  target_id = 
#  port = "${var.target_group_port}"
#}
