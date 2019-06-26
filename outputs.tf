output "lb_arn" {
  value = join("",aws_lb.lb.*.arn)
}

output "lb_zone_id" {
  value = join("",aws_lb.lb.*.zone_id)
}

output "lb_dns_name" {
  value = join("",aws_lb.lb.*.dns_name)
}

output "target_group_arns" {
  value = [
    for arn in aws_lb_target_group.target_group.*.arn:
      arn
  ]
}
