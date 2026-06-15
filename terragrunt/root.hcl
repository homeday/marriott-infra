# Root terragrunt.hcl
# This file contains common configuration that will be inherited by all child terragrunt.hcl files

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  region        = local.region_vars.locals.region
  name_prefix   = local.common_vars.locals.name_prefix

  common_tags = {
    Owner           = local.common_vars.locals.owner
    ManagedBy       = "Terragrunt"
    Repository_url  = "https://github.com/repo/terraform-aws-sample"
#    Repository_path = get_path_from_repo_root()
  }
}

remote_state {
  backend = "s3"
  
  config = {
    bucket         = "${local.name_prefix}-apple-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    use_lockfile   = true
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  
  contents = <<EOF
provider "aws" {
  region = "${local.region}"
  
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}
