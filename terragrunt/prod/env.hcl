locals {
  environment    = "production"
  env_short_name = "prod"
  account_tags = {
    environment    = local.environment
    env_short_name = local.env_short_name
  }
}