################################################################################
# VPC CNI Pod Identity
################################################################################

module "vpc_cni_pod_identity" {
  source                    = "terraform-aws-modules/eks-pod-identity/aws"
  version                   = "2.7.0"
  use_name_prefix           = false
  name                      = "${var.cluster_name}-vpc-cni-pod-id"
  policy_name_prefix        = "${var.cluster_name}-"
  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true
  tags                      = merge(var.tags, { "clusterName" = var.cluster_name })
}

################################################################################
# EBS CSI Driver Pod Identity
################################################################################

module "ebs_csi_pod_identity" {
  source                    = "terraform-aws-modules/eks-pod-identity/aws"
  version                   = "2.7.0"
  use_name_prefix           = false
  name                      = "${var.cluster_name}-ebs-csi-pod-id"
  policy_name_prefix        = "${var.cluster_name}-"
  attach_aws_ebs_csi_policy = true
  tags                      = merge(var.tags, { "clusterName" = var.cluster_name })
  depends_on                = [module.eks]
}

################################################################################
# AWS Load Balancer Controller Pod Identity
################################################################################

module "alb_controller_pod_identity" {
  source                          = "terraform-aws-modules/eks-pod-identity/aws"
  version                         = "2.7.0"
  use_name_prefix                 = false
  name                            = "${var.cluster_name}-alb-controller-pod-id"
  policy_name_prefix              = "${var.cluster_name}-"
  attach_aws_lb_controller_policy = true
  tags                            = merge(var.tags, { "clusterName" = var.cluster_name })

  associations = {
    main = {
      cluster_name    = module.eks.cluster_name
      namespace       = try(var.addons_settings["aws-load-balancer-controller"].namespace, "kube-system")
      service_account = try(var.addons_settings["aws-load-balancer-controller"].service_account, "aws-load-balancer-controller")
    }
  }
  depends_on = [module.eks]
}

module "cert_manager_eks_pod_identity" {
  source             = "terraform-aws-modules/eks-pod-identity/aws"
  version            = "2.7.0"
  use_name_prefix    = false
  name               = "${var.cluster_name}-cert-manager"
  policy_name_prefix = "${var.cluster_name}-"
  tags               = merge(var.tags, { "clusterName" = var.cluster_name })
  attach_cert_manager_policy = true
  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]
  associations = {
    main = {
      cluster_name    = var.cluster_name
      namespace       = try(var.addons_settings["cert-manager"].namespace, "cert-manager")
      service_account = try(var.addons_settings["cert-manager"].service_account, "aws-privateca-issuer-sa")
    }
  }
  depends_on = [module.eks]
}


module "external_secrets_eks_pod_identity" {
  source             = "terraform-aws-modules/eks-pod-identity/aws"
  version            = "2.7.0"
  use_name_prefix    = false
  name               = "${var.cluster_name}-external-secrets"
  policy_name_prefix = "${var.cluster_name}-"
  tags               = merge(var.tags, { "clusterName" = var.cluster_name })
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:${var.cluster_name}*",
                                           "arn:aws:secretsmanager:*:*:secret:rds!cluster*"]
  associations = {
    main = {
      cluster_name    = var.cluster_name
      namespace       = try(var.addons_settings["external-secrets"].namespace, "external-secrets")
      service_account = try(var.addons_settings["external-secrets"].service_account, "external-secrets-sa")
    }
  }
  depends_on = [module.eks]
  
}
