resource "aws_lb_target_group" "webserver_target" {
  name     = "webservertarget"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.application_vpc.id
}

resource "aws_lb_target_group_attachment" "instance_a" {
  target_group_arn = aws_lb_target_group.webserver_target.arn
  target_id        = aws_instance.webserver.id
  port             = 80
}


resource "aws_security_group" "allow_http_lb" {
  name        = "http"
  description = "Allow http"
  vpc_id      = aws_vpc.application_vpc.id

  ingress {
    description = "Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_lb" "web_lb" {
  name               = "weblb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_lb.id]
  subnets            = [ aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id ]

}

resource "aws_lb_listener" "webserver" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver_target.arn
  }
}

output "lb_public_dns_name" {
  value = aws_lb.web_lb.dns_name
}
