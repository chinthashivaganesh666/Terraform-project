resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = base64encode(local.web_user_data)

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-web"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${var.project_name}-web-asg"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = aws_subnet.public[*].id

  target_group_arns = [
    aws_lb_target_group.web.arn
  ]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  depends_on = [
    aws_lb_listener.web
  ]
}
