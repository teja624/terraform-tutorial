// Create a VPC corresponding to the production environment

module "environment" {
  source = "../modules/environment"
  environment_name = "prod"
}
