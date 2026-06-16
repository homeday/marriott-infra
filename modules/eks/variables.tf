variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "List of subnet IDs for the EKS control plane (if different from subnet_ids)"
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to cluster"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = []
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retention in days for the EKS control plane log group"
  type        = number
  default     = null
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = false
}

variable "authentication_mode" {
  description = "EKS authentication mode: API, CONFIG_MAP, or API_AND_CONFIG_MAP"
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["API", "CONFIG_MAP", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be one of: API, CONFIG_MAP, API_AND_CONFIG_MAP."
  }

  validation {
    condition     = !(var.authentication_mode == "API" && try(var.aws_auth_config.manage_aws_auth_configmap, false))
    error_message = "Cannot use manage_aws_auth_configmap=true with authentication_mode=API. Use CONFIG_MAP or API_AND_CONFIG_MAP instead."
  }

  validation {
    condition     = !(var.authentication_mode == "CONFIG_MAP" && length(var.access_entries) > 0)
    error_message = "Cannot use access_entries with authentication_mode=CONFIG_MAP. Use API or API_AND_CONFIG_MAP instead, or manage access via aws-auth ConfigMap."
  }
}

variable "access_entries" {
  description = "Map of EKS access entries (only valid with API or API_AND_CONFIG_MAP authentication modes)"
  type        = map(any)
  default     = {}
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions. If ami_id is not specified, the latest EKS-optimized AMI for the cluster version will be used automatically"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the cluster creator"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags for the EKS cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# AWS aws auth configmap management
################################################################################
variable "aws_auth_config" {
  description = "Configuration for managing the aws-auth configmap"
  type = object({
    manage_aws_auth_configmap = optional(bool, false)
    create_aws_auth_configmap = optional(bool, false)
    aws_auth_roles            = optional(list(any), [])
    aws_auth_users            = optional(list(any), [])
    aws_auth_accounts         = optional(list(string), [])
  })
  default = {}
}

################################################################################
# Core Addons Settings
################################################################################

variable "addons_settings" {
  description = "Unified settings for core addons (versions, configuration_values, resolve_conflicts, and timeouts)."
  type        = map(any)
  default     = {}

  validation {
    condition = length(
      setsubtract(
        toset(keys(var.addons_settings)),
        toset(["vpc-cni", "kube-proxy", "coredns", "eks-pod-identity-agent", "aws-ebs-csi-driver", "aws-load-balancer-controller", "cert-manager", "external-secrets"])
      )
    ) == 0
    error_message = "addons_settings only supports these keys: vpc-cni, kube-proxy, coredns, eks-pod-identity-agent, aws-ebs-csi-driver, aws-load-balancer-controller, cert-manager, external-secrets."
  }
}
