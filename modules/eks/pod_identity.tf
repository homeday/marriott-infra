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
