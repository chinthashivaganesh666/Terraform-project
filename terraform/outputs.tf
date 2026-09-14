output "application_url" {
  value = "http://${aws_lb.web.dns_name}"
}

output "public_alb_dns" {
  value = aws_lb.web.dns_name
}

output "internal_alb_dns" {
  value = aws_lb.app.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "web_asg_name" {
  value = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}

output "vpc_id" {
  value = aws_vpc.this.id
}
