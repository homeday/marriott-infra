# Shared EKS defaults for all environments
locals {
  eks_common_inputs = {
    cluster_version = "1.35"

    cluster_endpoint_public_access  = true
    cluster_endpoint_private_access = true

    authentication_mode = "API_AND_CONFIG_MAP"
    enable_irsa         = true

    eks_managed_node_groups = {
      default = {
        name           = "default-ng"
        instance_types = ["t3.medium"]
        min_size       = 1
        max_size       = 2
        desired_size   = 1
      }
    }

    addons_settings = {
      "eks-pod-identity-agent"      = {}
      "vpc-cni"                     = {}
      "kube-proxy"                  = {}
      "coredns"                     = {}
      "aws-ebs-csi-driver"          = {}
      "aws-load-balancer-controller" = {}
    }
  }
}
