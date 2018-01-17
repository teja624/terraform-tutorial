variable "name" { }
variable "cidr" { default = "10.0.0.0/16" }

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "${var.name}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}