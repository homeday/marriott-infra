resource "aws_rds_global_cluster" "this" {
  count = local.create_global_cluster ? 1 : 0

  global_cluster_identifier = "${var.cluster_name}-global"

  engine            = "aurora-postgresql"
  engine_version    = var.engine_version
  database_name     = local.is_primary ? var.database_name : null
  storage_encrypted = true
}

resource "aws_iam_role" "rds_ad_role" {
  count = local.create_iam_role_for_ad ? 1 : 0

  name = "rds-directory-service-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "rds_ad_policy" {
  count = local.create_iam_role_for_ad ? 1 : 0

  role       = aws_iam_role.rds_ad_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "10.2.0"

  name           = var.cluster_name
  create         = var.create
  engine         = local.engine
  port           = local.port
  engine_version = var.engine_version

  is_primary_cluster            = local.is_primary
  enable_http_endpoint          = true
  global_cluster_identifier     = local.global_cluster_id
  replication_source_identifier = var.replication_source_identifier
  database_name                 = local.is_primary ? var.database_name : null

  master_username             = local.is_primary ? "postgres" : null
  manage_master_user_password = false
  master_password_wo          = random_password.master[0].result
  master_password_wo_version  = 1

  domain               = var.aws_directory_service_id != null ? data.aws_directory_service_directory.aws_ad[0].id : null
  domain_iam_role_name = var.aws_directory_service_id != null ? aws_iam_role.rds_ad_role[0].name : null

  vpc_id                 = var.vpc_id
  create_db_subnet_group = var.db_subnet_group_name == null
  db_subnet_group_name   = var.db_subnet_group_name
  subnets                = var.db_subnet_group_name == null ? var.subnet_ids : null

  create_security_group = true
  security_group_ingress_rules = merge(
    local.security_group_ingress_cidr_rules,
    local.security_group_ingress_sg_rules
  )

  instances                          = local.final_instances
  cluster_instance_class             = var.instance_class
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration

  storage_encrypted            = var.storage_encrypted
  kms_key_id                   = var.kms_key_id
  backup_retention_period      = local.is_primary ? var.backup_retention_period : null
  preferred_backup_window      = local.is_primary ? var.preferred_backup_window : null
  preferred_maintenance_window = var.preferred_maintenance_window
  deletion_protection          = var.deletion_protection
  apply_immediately            = var.apply_immediately
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = local.final_snapshot_name

  cluster_monitoring_interval     = var.cluster_monitoring_interval
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  copy_tags_to_snapshot           = true

  cluster_parameter_group_name = var.cluster_parameter_group_name
  cluster_parameter_group      = var.cluster_parameter_group
  db_parameter_group           = var.db_parameter_group

  tags = merge(var.tags, {
    Role = local.is_primary ? "primary" : "secondary"
  })
}
