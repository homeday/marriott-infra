variable "cluster_name" {
  description = "Aurora cluster identifier"
  type        = string
}

variable "create" {
  description = "Whether to create the Aurora cluster"
  type        = bool
  default     = true
}

variable "deployment_type" {
  description = "Type of Aurora deployment in this region"
  type        = string
  default     = "standalone"

  validation {
    condition     = contains(["standalone", "global-primary", "global-secondary"], var.deployment_type)
    error_message = "deployment_type must be one of 'standalone', 'global-primary', or 'global-secondary'."
  }
}

variable "global_cluster_identifier" {
  description = "Existing global database identifier to join (required for DR region)"
  type        = string
  default     = null
}

variable "replication_source_identifier" {
  description = "Existing Aurora cluster identifier to replicate from (required for DR region)"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "database_name" {
  description = "Initial database name (primary only)"
  type        = string
  default     = "appdb"
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "subnet_ids" {
  description = "Database subnet IDs"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Database subnet group name"
  type        = string
  default     = ""
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Aurora PostgreSQL port"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to access Aurora PostgreSQL port"
  type        = list(string)
  default     = []
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "Number of Aurora instances in this region. Available only when custom_instances is empty."
  type        = number
  default     = 2
}

variable "custom_instances" {
  description = "Custom instance configurations. If provided, overrides generated instances."
  type        = any
  default     = {}
}

variable "serverlessv2_scaling_configuration" {
  description = "Map of nested attributes with serverless v2 scaling properties."
  type = object({
    min_capacity             = number
    max_capacity             = number
    seconds_until_auto_pause = optional(number, 300)
  })
  default = null

  validation {
    condition     = var.serverlessv2_scaling_configuration != null && var.instance_class == "db.serverless"
    error_message = "instance_class must be 'db.serverless' when serverlessv2_scaling_configuration is set."
  }

  validation {
    condition = var.serverlessv2_scaling_configuration == null || (
      var.serverlessv2_scaling_configuration.min_capacity >= 0.5 &&
      var.serverlessv2_scaling_configuration.max_capacity <= 128 &&
      var.serverlessv2_scaling_configuration.min_capacity <= var.serverlessv2_scaling_configuration.max_capacity
    )
    error_message = "Serverless scaling: min_capacity must be between 0.5 and 128 ACU, max_capacity between 0.5 and 128 ACU, and min_capacity must be <= max_capacity."
  }
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot when deleting the cluster. If not provided, a default name will be generated."
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = null
}

variable "kms_key_id" {
  description = "KMS key for encryption (optional)"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-05:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply modifications immediately"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a CloudWatch log group is created"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch log exports"
  type        = list(string)
  default     = ["postgresql"]
}

variable "cluster_monitoring_interval" {
  description = "Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB cluster. To turn off collecting Enhanced Monitoring metrics, specify 0. Valid Values: 0, 1, 5, 10, 15, 30, 60"
  type        = number
  default     = 0
}


################################################################################
# Cluster Parameter Group
################################################################################

variable "cluster_parameter_group_name" {
  description = "The name of an existing DB cluster parameter group. Required when `cluster_parameter_group` is not provided (`null`)"
  type        = string
  default     = null
}

variable "cluster_parameter_group" {
  description = "Map of nested arguments for the created DB cluster parameter group"
  type = object({
    name            = optional(string)
    use_name_prefix = optional(bool, true)
    description     = optional(string)
    family          = string
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate")
    })))
  })
  default = null
}

################################################################################
# DB Parameter Group
################################################################################

variable "db_parameter_group" {
  description = "Map of nested arguments for the created DB parameter group"
  type = object({
    name            = optional(string)
    use_name_prefix = optional(bool, true)
    description     = optional(string)
    family          = string
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate")
    })))
  })
  default = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "ad_user_name" {
  description = "Active Directory user name to create in the Aurora PostgreSQL database"
  type        = string
  default     = null
}


variable "aws_directory_service_id" {
  description = "AWS Directory Service ID for the Active Directory"
  type        = string
  default     = null
}

variable "ad_user_password" {
  description = "Active Directory user password to create in the Aurora PostgreSQL database"
  type        = string
  default     = null
}