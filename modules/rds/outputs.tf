output "cluster_id" {
  description = "Aurora cluster ID"
  value       = module.aurora.cluster_id
}

output "cluster_arn" {
  description = "Aurora cluster ARN"
  value       = module.aurora.cluster_arn
}

output "global_writer_endpoint" {
  description = "The global writer endpoint for the Aurora Global Database"
  value       = try(data.aws_rds_global_cluster.main[0].endpoint, null)
}

output "cluster_endpoint" {
  description = "Writer endpoint"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint"
  value       = module.aurora.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Aurora PostgreSQL port"
  value       = module.aurora.cluster_port
}

output "global_cluster_identifier" {
  description = "Global database identifier"
  value       = local.global_cluster_id
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = module.aurora.db_subnet_group_name
}

output "security_group_id" {
  description = "Security group ID for Aurora"
  value       = module.aurora.security_group_id
}

output "instance_identifiers" {
  description = "Aurora instance identifiers"
  value       = keys(module.aurora.cluster_instances)
}

output "cluster_master_user_secret" {
  description = "Generated database master user secret"
  value       = module.aurora.cluster_master_user_secret
  sensitive   = true
}
