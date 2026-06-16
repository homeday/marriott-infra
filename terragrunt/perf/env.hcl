locals {
  environment    = "performance"
  env_short_name = "perf"
  account_tags = {
    environment    = local.environment
    env_short_name = local.env_short_name
  }
}