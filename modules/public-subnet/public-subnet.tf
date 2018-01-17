variable "name"   { default = "public" }
variable "vpc_id" { }
variable "cidrs"  { }
variable "azs"    { }

// Create the public subnet
resource "aws_subnet" "public" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count = "${length(split(",", var.cidrs))}"
  tags {
    Name = "${var.name}.${element(split(",", var.azs),count.index)}"
  }
}

// Create an internet gateway
resource "aws_internet_gateway" "public" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.name}-subnet"
  }
}

// Create a public route table
// Allow outbound traffic to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public.id}"
  }
  tags {
    Name = "${var.name}.${element(split(",", var.azs),count.index)}"
  }
}

// Associate the subnet with the public route table
resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.cidrs))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

// Export the subnet IDs so we can reference them from elsewhere
output "subnet_ids" {
  value = "${join(",", aws_subnet.public.*.id)}"
}
