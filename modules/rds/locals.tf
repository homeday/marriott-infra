locals {
  is_global = contains([
    "global-primary",
    "global-secondary"
  ], var.deployment_type)
  port                   = "5432"
  engine                 = "aurora-postgresql"
  is_primary             = var.deployment_type != "global-secondary"
  create_global_cluster  = var.create && var.deployment_type == "global-primary"
  create_ad_user         = var.create && var.ad_user_name != null && var.aws_directory_service_id != null
  create_password_secret = var.create && local.is_primary
  create_iam_role_for_ad = var.create && var.aws_directory_service_id != null
  global_cluster_id      = local.create_global_cluster ? aws_rds_global_cluster.this[0].id : var.global_cluster_identifier

  generated_instances = var.instance_count > 0 ? {
    for i in range(var.instance_count) : "instance_${i + 1}" => {
      identifier = "${var.cluster_name}-${i + 1}"
    }
  } : {}
  final_instances = length(var.custom_instances) > 0 ? var.custom_instances : local.generated_instances

  security_group_ingress_cidr_rules = {
    for i, cidr in var.allowed_cidr_blocks : "cidr_${i}" => {
      cidr_ipv4   = cidr
      from_port   = local.port
      to_port     = local.port
      ip_protocol = "tcp"
      description = "PostgreSQL from allowed CIDR"
    }
  }
  security_group_ingress_sg_rules = {
    for i, sg_id in var.allowed_security_group_ids : "sg_${i}" => {
      referenced_security_group_id = sg_id
      from_port                    = local.port
      to_port                      = local.port
      ip_protocol                  = "tcp"
      description                  = "PostgreSQL from allowed security group"
    }
  }

  final_snapshot_name = var.skip_final_snapshot ? null : (
    var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.cluster_name}-final-snapshot"
  )
}
