locals {
  is_global = contains([
    "global-primary",
    "global-secondary"
  ], var.deployment_type)

  is_primary = var.deployment_type != "global-secondary"

  create_global_cluster = var.deployment_type == "global-primary"

  global_cluster_id = local.create_global_cluster ? aws_rds_global_cluster.this[0].id : var.global_cluster_identifier

  should_create_instances = var.deployment_mode == "provisioned" && var.instance_count > 0

  instances = local.should_create_instances ? {
    for i in range(var.instance_count) : "instance_${i + 1}" => {
      identifier = "${var.cluster_name}-${i + 1}"
    }
  } : {}

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
}

resource "aws_secretsmanager_secret" "db" {
  count = local.is_primary ? 1 : 0
  name  = "rds-aurora/${var.cluster_name}-master"
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = local.is_primary ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id

  secret_string = jsonencode({
    username = "postgres"
    password = random_password.master[0].result
  })
}

resource "random_password" "master" {
  count   = local.is_primary ? 1 : 0
  length  = 20
  special = false
  keepers = {
    version = 2
  }
}

resource "aws_rds_global_cluster" "this" {
  count = local.create_global_cluster ? 1 : 0

  global_cluster_identifier = "${var.cluster_name}-global"

  engine            = "aurora-postgresql"
  engine_version    = var.engine_version
  database_name     = local.is_primary ? var.database_name : null
  storage_encrypted = true
}

data "aws_rds_global_cluster" "main" {
  count = local.is_primary ? 1 : 0
  identifier = local.global_cluster_id
  depends_on = [module.aurora]
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "10.2.0"

  name = var.cluster_name

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  port           = var.port

  is_primary_cluster = local.is_primary
  enable_http_endpoint      = true

  global_cluster_identifier     = local.global_cluster_id
  replication_source_identifier = var.replication_source_identifier

  database_name   = local.is_primary ? var.database_name : null
  master_username = local.is_primary ? "postgres" : null

  manage_master_user_password = false
  master_password_wo          = random_password.master[0].result
  master_password_wo_version  = 1

  db_subnet_group_name = var.db_subnet_group_name

  create_security_group = true
  vpc_id                = var.vpc_id

  security_group_ingress_rules = merge(
    local.security_group_ingress_cidr_rules,
    local.security_group_ingress_sg_rules
  )

  instances                          = local.instances
  cluster_instance_class             = var.deployment_mode == "provisioned" ? var.instance_class : null
  serverlessv2_scaling_configuration = var.deployment_mode == "serverless_v2" ? var.serverless_scaling_configuration : null

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  backup_retention_period      = local.is_primary ? var.backup_retention_period : null
  preferred_backup_window      = local.is_primary ? var.preferred_backup_window : null
  preferred_maintenance_window = var.preferred_maintenance_window

  create_cloudwatch_log_group     = var.create_cloudwatch_log_group
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection       = var.deletion_protection
  apply_immediately         = var.apply_immediately
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_name}-final"

  tags = merge(var.tags, {
    Module = "rds"
    Role   = local.is_primary ? "primary" : "secondary"
  })
}
