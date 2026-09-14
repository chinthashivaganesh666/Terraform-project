resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path    = "/"
    matcher = "200-399"
  }

  tags = {
    Name = "${var.project_name}-web-tg"
  }
}

resource "aws_lb" "web" {
  name               = "${var.project_name}-web-alb"
  load_balancer_type = "application"
  internal           = false

  subnets = aws_subnet.public[*].id

  security_groups = [
    aws_security_group.public_alb.id
  ]

  tags = {
    Name = "${var.project_name}-web-alb"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path    = "/health"
    matcher = "200"
  }

  tags = {
    Name = "${var.project_name}-app-tg"
  }
}

resource "aws_lb" "app" {
  name               = "${var.project_name}-internal-alb"
  load_balancer_type = "application"
  internal           = true

  subnets = aws_subnet.app[*].id

  security_groups = [
    aws_security_group.internal_alb.id
  ]

  tags = {
    Name = "${var.project_name}-internal-alb"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
