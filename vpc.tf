resource "aws_vpc" "application_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.application_vpc.id

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.application_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public route table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "http_ssh"
  description = "Allow http ssh"
  vpc_id      = aws_vpc.application_vpc.id

  ingress {
    description = "Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "webserver" {
  ami                         = "ami-0d593311db5abb72b"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_a.id
  security_groups             = [aws_security_group.allow_http_ssh.id]
  user_data                   = file("userdata.sh")
}

output "ec2_public_ip" {
  value = aws_instance.webserver.public_ip
}
