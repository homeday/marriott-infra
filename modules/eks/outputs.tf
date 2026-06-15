output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS worker nodes"
  value       = module.eks.node_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}
output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "OIDC provider URL for EKS"
  value       = module.eks.oidc_provider
}

output "vpc_id" {
  description = "VPC ID of the EKS cluster"
  value       = var.vpc_id
}

output "eks_managed_node_groups" {
  description = "Compact summary of EKS managed node groups"
  value = {
    for k, v in module.eks.eks_managed_node_groups : k => {
      asg_names  = v.node_group_autoscaling_group_names
      arn        = v.node_group_arn
      status     = v.node_group_status
      resources  = v.node_group_resources
      grp_taints = v.node_group_taints
      grp_labels = v.node_group_labels
    }
  }
}

output "self_managed_node_groups" {
  description = "Compact summary of self-managed node groups"
  value = {
    for k, v in module.eks.self_managed_node_groups : k => {
      asg_arn             = v.autoscaling_group_arn
      launch_template_arn = v.launch_template_arn
      iam_role_name       = v.iam_role_name
    }
  }
}

output "default_ami_id" {
  description = "The default EKS-optimized AMI ID used for self-managed nodes"
  value       = data.aws_ami.eks_default.id
}

output "default_ami_name" {
  description = "The name of the default EKS-optimized AMI"
  value       = data.aws_ami.eks_default.name
}

output "core_addons" {
  description = "Map of core addons managed by the EKS module"
  value = {
    for k, v in module.eks.cluster_addons : k => {
      arn                      = v.arn
      addon_version            = v.addon_version
      pod_identity_association = v.pod_identity_association
      service_account_role_arn = v.service_account_role_arn
    }
  }
}

output "vpc_cni_iam_role_arn" {
  description = "The IAM role ARN used by the vpc-cni (Pod Identity)"
  value       = module.vpc_cni_pod_identity.iam_role_arn
}

output "ebs_csi_iam_role_arn" {
  description = "The IAM role ARN used by the ebs-csi-driver (Pod Identity)"
  value       = module.ebs_csi_pod_identity.iam_role_arn
}

output "alb_controller_iam_role_arn" {
  description = "The IAM role ARN used by the aws-load-balancer-controller (Pod Identity)"
  value       = module.alb_controller_pod_identity.iam_role_arn
}