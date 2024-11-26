resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = "${var.lb_port}"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.coderd-group.arn
  }
}

resource "aws_lb_target_group" "coderd-group" {
  name     = var.target_group_name
  port     = var.target_port
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/healthz"
    port    = var.healthcheck_port
  }
}

resource "aws_lb_target_group_attachment" "attach" {

  depends_on = [ aws_lb_listener.listener ]

  target_group_arn = aws_lb_target_group.coderd-group.arn
  target_id        = var.instance_id
  port             = var.target_port
}