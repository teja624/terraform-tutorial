// Create a VPC corresponding to the development environment

module "environment" {
  source = "../modules/environment"
  environment_name = "dev"
}
