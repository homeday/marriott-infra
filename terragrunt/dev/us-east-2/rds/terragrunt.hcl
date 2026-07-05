# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  rds_common  = read_terragrunt_config("${get_terragrunt_dir()}/../../../_envcom/rds.hcl")

  cluster_name = "aws-rds-dev-use2"
}

terraform {
  source = "${get_original_terragrunt_dir()}/../../../../modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                     = "vpc-00000000000000000"
    vpc_cidr_block             = "10.5.0.0/20"
    database_subnet_group_name = "aws-vpc-2-db-subnet-group"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = merge(
  local.rds_common.locals.rds_common_inputs,
  {
    cluster_name         = local.cluster_name
    instance_count       = 1
    vpc_id               = dependency.vpc.outputs.vpc_id
    db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
    availability_zones   = dependency.vpc.outputs.azs
    allowed_cidr_blocks  = [dependency.vpc.outputs.vpc_cidr_block]
    tags = merge(
      try(local.env_vars.locals.account_tags, {}),
      {
        environment = "dev"
        component   = "rds"
        role        = "primary"
      }
    )
  }
)
