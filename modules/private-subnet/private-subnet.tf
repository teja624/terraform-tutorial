//   modules/private-subnet/private-subnet.tf
variable "name" { default = "private"}
variable "vpc_id" { }
variable "cidrs" { }
variable "azs" { }
variable "nat_gateway_ids" { }

resource "aws_subnet" "private" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count = "${length(split(",", var.cidrs))}"
  lifecycle { create_before_destroy = true }
  tags {
    Name = "${var.name}.${element(split(",", var.azs),count.index)}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  count  = "${length(split(",", var.cidrs))}"
  lifecycle { create_before_destroy = true }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
  }
  tags {
    Name = "${var.name}.${element(split(",", var.azs),count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(split(",", var.cidrs))}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  lifecycle { create_before_destroy = true }
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

output "subnet_ids" {
  value = "${join(",", aws_subnet.private.*.id)}"
}