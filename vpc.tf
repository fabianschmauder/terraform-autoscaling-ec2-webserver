resource "aws_vpc" "application_vpc" {
  cidr_block = var.vpc_cidr_block
}