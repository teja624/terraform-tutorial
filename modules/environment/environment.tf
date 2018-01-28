//  modules/environment/environment.tf
variable "environment_name" {}
variable "azs" { default = "us-east-1a,us-east-1b" }

// Specify AWS as the provider and reference credentials
provider "aws" {
  region = "us-east-1"
  profile = "terraform_user"
}

// Create a VPC
module "vpc" {
  source = "../vpc"
  name = "${var.environment_name}-vpc"
}

// Create a public subnet referencing the vpc
module "public_subnet" {
  source = "../public-subnet"
  name = "public-subnet"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "10.0.1.0/24,10.0.2.0/24"
  azs = "${var.azs}"     // availability zones
}

module "private_subnet" {
  source = "../private-subnet"
  name = "private-subnet"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "10.0.11.0/24,10.0.12.0/24"
  azs = "${var.azs}"
  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}
module "nat" {
  source = "../nat"
  name = "nat"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

resource "aws_network_acl" "nacl" {
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = [
    "${split(",", module.private_subnet.subnet_ids)}",
    "${split(",", module.public_subnet.subnet_ids)}"
  ]
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags {
    Name = "network-acl"
  }
}