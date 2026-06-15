locals {
  global_cluster_id = var.create_global_cluster ? "${var.cluster_name}-global" : var.global_cluster_identifier

  security_group_ingress_cidr_rules = {
    for i, cidr in var.allowed_cidr_blocks : "cidr_${i}" => {
      cidr_ipv4   = cidr
      from_port   = var.port
      to_port     = var.port
      ip_protocol = "tcp"
      description = "PostgreSQL from allowed CIDR"
    }
  }

  security_group_ingress_sg_rules = {
    for i, sg_id in var.allowed_security_group_ids : "sg_${i}" => {
      referenced_security_group_id = sg_id
      from_port                    = var.port
      to_port                      = var.port
      ip_protocol                  = "tcp"
      description                  = "PostgreSQL from allowed security group"
    }
  }

  instances = {
    for i in range(var.instance_count) : "instance_${i + 1}" => {
      identifier = "${var.cluster_name}-${i + 1}"
    }
  }
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "10.2.0"

  name = var.cluster_name

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  port           = var.port

  is_primary_cluster        = var.is_primary
  global_cluster_identifier = local.global_cluster_id

  database_name   = var.is_primary ? var.database_name : null
  master_username = var.is_primary ? var.master_username : null

  manage_master_user_password = var.is_primary ? var.manage_master_user_password : false
  master_password_wo          = var.is_primary && !var.manage_master_user_password ? var.master_password : null

  create_db_subnet_group = true
  subnets                = var.subnet_ids

  create_security_group = true
  vpc_id                = var.vpc_id
  security_group_ingress_rules = merge(
    local.security_group_ingress_cidr_rules,
    local.security_group_ingress_sg_rules
  )

  cluster_instance_class = var.instance_class
  instances              = local.instances

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  backup_retention_period      = var.is_primary ? var.backup_retention_period : null
  preferred_backup_window      = var.is_primary ? var.preferred_backup_window : null
  preferred_maintenance_window = var.preferred_maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection       = var.deletion_protection
  apply_immediately         = var.apply_immediately
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_name}-final"

  tags = merge(var.tags, {
    Module = "rds"
    Role   = var.is_primary ? "primary" : "dr"
  })
}
