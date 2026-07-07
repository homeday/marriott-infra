data "aws_rds_global_cluster" "main" {
  count      = local.is_primary ? 1 : 0
  identifier = local.global_cluster_id
  depends_on = [module.aurora]
}

data "aws_directory_service_directory" "aws_ad" {
  count        = var.aws_directory_service_id != null ? 1 : 0
  directory_id = var.aws_directory_service_id
}
