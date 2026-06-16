 # Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  eks_common  = read_terragrunt_config("${get_terragrunt_dir()}/../../../_envcom/eks.hcl")

  cluster_name = "aws-eks-stg-use2"
}

terraform {
  source = "${get_original_terragrunt_dir()}/../../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-00000000000000000"
    private_subnets = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = merge(
  local.eks_common.locals.eks_common_inputs,
  {
    cluster_name = local.cluster_name

    vpc_id     = dependency.vpc.outputs.vpc_id
    subnet_ids = dependency.vpc.outputs.private_subnets

    eks_managed_node_groups = {
      for k, v in local.eks_common.locals.eks_common_inputs.eks_managed_node_groups :
      k => merge(v, {
        subnet_ids = dependency.vpc.outputs.private_subnets
      })
    }

    tags = merge(
      try(local.env_vars.locals.account_tags, {}),
      {
        environment = "staging"
        component   = "eks"
      }
    )
  }
)