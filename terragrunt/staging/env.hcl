locals {
  environment    = "staging"
  env_short_name = "stg"
  account_tags = {
    environment    = local.environment
    env_short_name = local.env_short_name
  }
}