provider "aws" {
  region = "us-east-1"
  profile = "terraform_user"
}

module "vpc" {
  source = "../modules/vpc"
  name = "dev-vpc"
}

module "public_subnet" {
  source = "../modules/public-subnet"
  name = "public-subnet"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "10.0.1.0/24,10.0.2.0/24"
  azs = "us-east-1a,us-east-1b"
}

module "private_subnet" {
  source = "../modules/private-subnet"
  name = "private-subnet"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "10.0.11.0/24,10.0.12.0/24"
  azs = "us-east-1a,us-east-1b"
  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}
module "nat" {
  source = "../modules/nat"
  name = "nat"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}
