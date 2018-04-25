# Network load balancer to allow access to the server thrugh a VPCLink
# https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started-with-private-integration.html
resource "aws_lb" "our_nlb" {
  name = "nlb"
  load_balancer_type = "network"

  subnets = ["${aws_subnet.eu-central-1-public.id}"]

  #TODO: add security groups
}

# Target group for the load balancer: allow HTTP traffic
resource "aws_lb_target_group" "our_instance_http" {
  port = "80"
  protocol = "TCP"
  vpc_id = "${aws_vpc.eu-central-1.id}"

  stickiness {
    type = "lb_cookie"
    enabled = false
  }
}

resource "aws_lb_target_group_attachment" "our_instance_http" {
  target_group_arn = "${aws_lb_target_group.our_instance_http.arn}"
  target_id        = "${aws_instance.aws_instance.id}"
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.our_nlb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.our_instance_http.arn}"
    type             = "forward"
  }
}