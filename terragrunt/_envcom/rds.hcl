# Shared RDS defaults for all environments
locals {
  rds_common_inputs = {
    engine_version = "15.4"

    is_primary            = true
    create_global_cluster  = false
    manage_master_user_password = true

    database_name = "appdb"
    master_username = "postgres"

    instance_class = "db.r6g.large"
    instance_count = 1

    storage_encrypted = true
    backup_retention_period = 7
    preferred_backup_window = "03:00-05:00"
    preferred_maintenance_window = "sun:05:00-sun:06:00"

    deletion_protection = false
    apply_immediately   = true
    skip_final_snapshot = true

    enabled_cloudwatch_logs_exports = ["postgresql"]
    port                           = 5432
  }
}
