output "lb_arn" {
  value = "${local.lb_arn}"
}

output "lb_zone_id" {
  value = "${local.lb_zone_id}"
}

output "lb_dns_name" {
  value = "${local.lb_dns_name}"
}

output "target_group_arns" {
  value = "${join(" ", aws_lb_target_group.target_group.*.arn)}"
}
