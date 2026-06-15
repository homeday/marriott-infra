locals {
  environment    = "developer"
  env_short_name = "dev"
  account_tags = {
    environment = local.environment
    env_short_name = local.env_short_name
  }
}