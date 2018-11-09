output "lb_arn" {
  value = "${aws_lb.lb.arn}"
}

output "lb_zone_id" {
  value = "${aws_lb.lb.zone_id}"
}

output "lb_dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "target_group_arns" {
  value = "${join(" ", aws_lb_target_group.target_group.*.arn)}"
}
