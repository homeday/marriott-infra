data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-al2023-x86_64-standard-${var.cluster_version}-v*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Process self-managed node groups to add default AMI if not specified
locals {
  eks_managed_node_groups_with_defaults = {
    for k, v in var.eks_managed_node_groups : k => merge(
      {
        create_iam_role          = true
        iam_role_use_name_prefix = false
        iam_role_name            = "${var.cluster_name}-${k}-ng-role"
      },
      v
    )
  }

  self_managed_node_groups_with_defaults = {
    for k, v in var.self_managed_node_groups : k => merge(
      v,
      {
        ami_id = lookup(v, "ami_id", null) != null ? v.ami_id : data.aws_ami.eks_default.id
      }
    )
  }
}

# Reference the official EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.19.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  # Cluster endpoint access
  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  # Networking
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  control_plane_subnet_ids      = var.control_plane_subnet_ids
  additional_security_group_ids = var.additional_security_group_ids

  # Cluster logging
  enabled_log_types                      = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  # IRSA / OIDC
  enable_irsa = var.enable_irsa

  # EKS access entries
  access_entries = var.access_entries

  # Authentication mode
  authentication_mode = var.authentication_mode

  addons = {
    eks-pod-identity-agent = {
      before_compute              = true
      addon_version               = try(var.addons_settings["eks-pod-identity-agent"].addon_version, var.addons_settings["eks-pod-identity-agent"].version, null)
      timeouts                    = try(var.addons_settings["eks-pod-identity-agent"].timeouts, {})
      resolve_conflicts_on_create = try(var.addons_settings["vpc-cni"].resolve_conflicts_on_create, "OVERWRITE")
      resolve_conflicts_on_update = try(var.addons_settings["vpc-cni"].resolve_conflicts_on_update, "PRESERVE")
    }
    vpc-cni = {
      before_compute = true
      addon_version  = try(var.addons_settings["vpc-cni"].addon_version, var.addons_settings["vpc-cni"].version, null)
      pod_identity_association = [{
        role_arn        = module.vpc_cni_pod_identity.iam_role_arn
        service_account = "aws-node"
      }]

      resolve_conflicts_on_create = try(var.addons_settings["vpc-cni"].resolve_conflicts_on_create, "OVERWRITE")
      resolve_conflicts_on_update = try(var.addons_settings["vpc-cni"].resolve_conflicts_on_update, "PRESERVE")
      configuration_values = jsonencode(merge({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      }, try(var.addons_settings["vpc-cni"].configuration_values, {})))

      force_detach_policies = true
      max_session_duration  = 7200

      timeouts = try(var.addons_settings["vpc-cni"].timeouts, {
        create = "20m"
        update = "40m"
        delete = "30m"
      })
    }
    kube-proxy = {
      before_compute              = true
      addon_version               = try(var.addons_settings["kube-proxy"].addon_version, var.addons_settings["kube-proxy"].version, null)
      resolve_conflicts_on_create = try(var.addons_settings["kube-proxy"].resolve_conflicts_on_create, "OVERWRITE")
      resolve_conflicts_on_update = try(var.addons_settings["kube-proxy"].resolve_conflicts_on_update, "PRESERVE")
      configuration_values        = try(var.addons_settings["kube-proxy"].configuration_values, null) != null ? jsonencode(var.addons_settings["kube-proxy"].configuration_values) : null
      timeouts                    = try(var.addons_settings["kube-proxy"].timeouts, {})
    }
    coredns = {
      before_compute              = false
      addon_version               = try(var.addons_settings["coredns"].addon_version, var.addons_settings["coredns"].version, null)
      resolve_conflicts_on_create = try(var.addons_settings["coredns"].resolve_conflicts_on_create, "OVERWRITE")
      resolve_conflicts_on_update = try(var.addons_settings["coredns"].resolve_conflicts_on_update, "PRESERVE")
      configuration_values        = try(var.addons_settings["coredns"].configuration_values, null) != null ? jsonencode(var.addons_settings["coredns"].configuration_values) : null
      timeouts                    = try(var.addons_settings["coredns"].timeouts, {})
    }
    # aws-ebs-csi-driver = {
    #   before_compute = false
    #   addon_version  = try(var.addons_settings["aws-ebs-csi-driver"].addon_version, var.addons_settings["aws-ebs-csi-driver"].version, null)
    #   pod_identity_association = [{
    #     role_arn        = module.ebs_csi_pod_identity.iam_role_arn
    #     service_account = "ebs-csi-controller-sa"
    #   }]
    #   resolve_conflicts_on_create = try(var.addons_settings["aws-ebs-csi-driver"].resolve_conflicts_on_create, "OVERWRITE")
    #   resolve_conflicts_on_update = try(var.addons_settings["aws-ebs-csi-driver"].resolve_conflicts_on_update, "PRESERVE")
    #   configuration_values        = try(var.addons_settings["aws-ebs-csi-driver"].configuration_values, null) != null ? jsonencode(var.addons_settings["aws-ebs-csi-driver"].configuration_values) : null
    #   timeouts                    = try(var.addons_settings["aws-ebs-csi-driver"].timeouts, {})
    # }
    # aws-load-balancer-controller = {
    #   before_compute = false
    #   addon_version  = try(var.addons_settings["aws-load-balancer-controller"].addon_version, var.addons_settings["aws-load-balancer-controller"].version, null)
    #   pod_identity_association = [{
    #     role_arn        = module.alb_controller_pod_identity.iam_role_arn
    #     service_account = "aws-load-balancer-controller"
    #   }]
    #   resolve_conflicts_on_create = try(var.addons_settings["aws-load-balancer-controller"].resolve_conflicts_on_create, "OVERWRITE")
    #   resolve_conflicts_on_update = try(var.addons_settings["aws-load-balancer-controller"].resolve_conflicts_on_update, "PRESERVE")
    #   configuration_values        = try(var.addons_settings["aws-load-balancer-controller"].configuration_values, null) != null ? jsonencode(var.addons_settings["aws-load-balancer-controller"].configuration_values) : null
    #   timeouts                    = try(var.addons_settings["aws-load-balancer-controller"].timeouts, {})
    # }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = local.eks_managed_node_groups_with_defaults

  # Self Managed Node Groups (with default AMI applied)
  self_managed_node_groups = local.self_managed_node_groups_with_defaults

  # Cluster access entry
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Tags
  tags         = merge(var.tags, { ManagedBy = "Terraform", Module = "eks" })
  cluster_tags = var.cluster_tags
}


resource "aws_eks_addon" "aws_ebs_csi_driver_addon" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  addon_version               = try(var.addons_settings["aws-ebs-csi-driver"].addon_version, var.addons_settings["aws-ebs-csi-driver"].version, null)
  configuration_values        = try(var.addons_settings["aws-ebs-csi-driver"].configuration_values, null) != null ? jsonencode(var.addons_settings["aws-ebs-csi-driver"].configuration_values) : null
  preserve                    = try(var.addons_settings["aws-ebs-csi-driver"].preserve, true)
  resolve_conflicts_on_create = try(var.addons_settings["aws-ebs-csi-driver"].resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(var.addons_settings["aws-ebs-csi-driver"].resolve_conflicts_on_update, "PRESERVE")
  pod_identity_association {
    role_arn        = module.ebs_csi_pod_identity.iam_role_arn
    service_account = "ebs-csi-controller-sa"
  }

  timeouts {
    create = try(var.addons_settings["aws-ebs-csi-driver"].timeouts.create, null)
    update = try(var.addons_settings["aws-ebs-csi-driver"].timeouts.update, null)
    delete = try(var.addons_settings["aws-ebs-csi-driver"].timeouts.delete, null)
  }
  tags       = var.tags
  depends_on = [module.eks]
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"
  depends_on = [module.eks]

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    chart_version   = "3.2.2"
    create_role = false
    service_account_name = "aws-load-balancer-controller"
    namespace = "kube-system"
    set = [
      {
        name  = "vpcId"
        value = var.vpc_id
      }
    ]
  }
}
