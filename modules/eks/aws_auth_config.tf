locals {
  aws_auth_config           = try(var.aws_auth_config, {})
  manage_aws_auth_configmap = try(local.aws_auth_config.manage_aws_auth_configmap, false)
  aws_auth_roles            = try(local.aws_auth_config.aws_auth_roles, [])
  aws_auth_users            = try(local.aws_auth_config.aws_auth_users, [])
  aws_auth_accounts         = try(local.aws_auth_config.aws_auth_accounts, [])
}

module "aws_auth" {
  count   = local.manage_aws_auth_configmap ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = local.manage_aws_auth_configmap
  create_aws_auth_configmap = false
  aws_auth_roles            = local.aws_auth_roles
  aws_auth_users            = local.aws_auth_users
  aws_auth_accounts         = local.aws_auth_accounts

  depends_on = [module.eks]
}
