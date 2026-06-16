locals {
  environment    = "qa"
  env_short_name = "qa"
  account_tags = {
    environment    = local.environment
    env_short_name = local.env_short_name
  }
}