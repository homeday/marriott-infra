locals {
  aws_auth_config           = try(var.aws_auth_config, {})
  manage_aws_auth_configmap = try(local.aws_auth_config.manage_aws_auth_configmap, false)
  aws_auth_roles            = try(local.aws_auth_config.aws_auth_roles, [])
  aws_auth_users            = try(local.aws_auth_config.aws_auth_users, [])
  aws_auth_accounts         = try(local.aws_auth_config.aws_auth_accounts, [])
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", data.aws_region.current.region]
#   }
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", data.aws_region.current.region]
#     }
#   }
# }

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
