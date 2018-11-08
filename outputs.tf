output "aws_lb_arn" {
  value = "${aws_lb.lb.arn}"
}

output "aws_lb_zone_id" {
  value = "${aws_lb.lb.zone_id}"
}

output "aws_lb_dns_name" {
  value = "${aws_lb.lb.dns_name}"
}
