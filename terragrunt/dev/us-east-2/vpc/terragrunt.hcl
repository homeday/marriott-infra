# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Load account-specific configuration from JSON
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vpc_common = read_terragrunt_config("${get_terragrunt_dir()}/../../../_envcom/vpc.hcl")
  # Extract the name prefix for easy access
  name_prefix = local.common_vars.locals.name_prefix

  vpc_name           = "aws-vpc-2"
  vpc_cidr           = "10.5.0.0/20"
  availability_zones = ["us-east-2a", "us-east-2b"]
}

# Terragrunt will copy the Terraform configurations specified by the source parameter
terraform {
  source = "${get_original_terragrunt_dir()}/../../../../modules/vpc"
}

# Module inputs
inputs = merge(
  local.vpc_common.locals.vpc_common_inputs,
  {
    vpc_name           = local.vpc_name
    vpc_cidr           = local.vpc_cidr
    availability_zones = local.availability_zones
    # Subnet configuration from JSON
    public_subnet_cidrs = [
      for i, az in local.availability_zones : cidrsubnet(local.vpc_cidr, 4, i + 1)
    ]
    private_subnet_cidrs = [
      for i, az in local.availability_zones : cidrsubnet(local.vpc_cidr, 4, i + 5)
    ]
    database_subnet_cidrs = [
      for i, az in local.availability_zones : cidrsubnet(local.vpc_cidr, 4, i + 13)
    ]
    # tags = merge(
    #   local.common_vars.locals.common_tags,
    #   {
    #     Component = "networking"
    #   }
    # )
  }
)
