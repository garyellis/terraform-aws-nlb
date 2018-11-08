resource "aws_lb" "lb" {
  name = "${var.name}"
  enable_cross_zone_load_balancing = "${length(var.subnets) > 1 ? "true" : "false"}"
  internal = "${var.internal}"
  load_balancer_type = "network"
  enable_deletion_protection = "${var.enable_deletion_protection}"
  subnets = ["${var.subnets}"]
	tags = "${merge(map("Name", var.name), var.tags)}"
}

resource "aws_lb_listener" "lb_listener" {
  protocol = "TCP"
  port = "${var.lb_listener_port}"
  load_balancer_arn = "${aws_lb.lb.arn}"

  default_action {
    #target_group_arn = "${aws_lb_target_group.lb_target_group.arn}"
    target_group_arn = "${local.target_group_arn}"
    type = "forward"
  }
}

resource "aws_lb_target_group" "lb_target_group_instance" {
  count = "${var.target_group_type == "instance" ? 1 : 0}"

  name = "${var.name}-tcp${var.target_group_port}"
  port = "${var.target_group_port}"
  proxy_protocol_v2 = "false"
  protocol = "TCP"
  target_type = "instance"
  vpc_id = "${var.vpc_id}"

  # Health check healthy threshold and unhealthy threshold must be the same for target groups with the TCP protocol
  # Custom health check timeouts are not currently supported for health checks for target groups with the TCP protocol
  # we need to parameterize health check into a map
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    path = "/healthz"
    protocol = "HTTPS"
  }
  tags = "${merge(map("Name", var.name), var.tags)}"
}


# use ip target type when routing traffic to a secondary ip, secondary interface or when hairpinning or loopback is required.
resource "aws_lb_target_group" "lb_target_group_ip" {
  count = "${var.target_group_type == "ip" ? 1 : 0}"

  name = "${var.name}-tcp${var.target_group_port}"
  port = "${var.target_group_port}"
  proxy_protocol_v2 = "false"
  protocol = "TCP"
  target_type = "ip"
  vpc_id = "${var.vpc_id}"

  # we need to paramaterize health  check into a map
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    path = "/healthz"
    protocol = "HTTPS"
  }
  tags = "${merge(map("Name", var.name), var.tags)}"
}

locals {
  target_group_arn = "${join(",", aws_lb_target_group.lb_target_group_instance.*.arn, aws_lb_target_group.lb_target_group_ip.*.arn)}"
}

resource "aws_lb_target_group_attachment" "attachments" {
  count = "${length(var.target_group_attachments)}"

  target_group_arn = "${local.target_group_arn}"
  target_id = "${var.target_group_attachments[count.index]}"
  port = "${var.target_group_port}"
}
