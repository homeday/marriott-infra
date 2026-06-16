variable "cluster_name" {
  description = "Aurora cluster identifier"
  type        = string
}

variable "is_primary" {
  description = "Whether this region is the primary cluster for global database"
  type        = bool
  default     = true
}

variable "create_global_cluster" {
  description = "Create a new Aurora global database identifier in primary region"
  type        = bool
  default     = false

  validation {
    condition     = !(var.create_global_cluster && !var.is_primary)
    error_message = "create_global_cluster can only be true when is_primary is true."
  }
}

variable "global_cluster_identifier" {
  description = "Existing global database identifier to join (required for DR region)"
  type        = string
  default     = null
}

variable "deployment_mode" {
  description = "deployment mode: 'provisioned' or 'serverless_v2'"
  type        = string
  default     = "provisioned"
  
  validation {
    condition     = contains(["provisioned", "serverless_v2"], var.deployment_mode)
    error_message = "deployment_mode must be either 'provisioned' or 'serverless_v2'."
  }
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

variable "master_username" {
  description = "Master username (primary only)"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password (only used if manage_master_user_password is false)"
  type        = string
  default     = null
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Use AWS managed master password in Secrets Manager"
  type        = bool
  default     = true

  validation {
    condition     = var.manage_master_user_password || var.master_password != null
    error_message = "When manage_master_user_password is false, master_password must be provided."
  }
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "subnet_ids" {
  description = "Database subnet IDs"
  type        = list(string)
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

  validation {
    condition     = var.deployment_mode != "provisioned" || var.instance_class != null
    error_message = "instance_class is required when deployment_mode is 'provisioned'."
  }
}

variable "serverless_scaling_configuration" {
  description = "Configuration for Serverless v2 scaling. Required when deployment_mode = 'serverless_v2'."
  type = object({
    min_capacity = number
    max_capacity = number
    seconds_until_auto_pause = optional(number, 300)
  })
  default = null

  validation {
    condition     = var.deployment_mode != "serverless_v2" || var.serverless_scaling_configuration != null
    error_message = "serverless_scaling_configuration is required when deployment_mode is 'serverless_v2'."
  }

  validation {
    condition     = var.serverless_scaling_configuration == null || (
      var.serverless_scaling_configuration.min_capacity >= 0.5 &&
      var.serverless_scaling_configuration.max_capacity <= 128 &&
      var.serverless_scaling_configuration.min_capacity <= var.serverless_scaling_configuration.max_capacity
    )
    error_message = "Serverless scaling: min_capacity must be between 0.5 and 128 ACU, max_capacity between 0.5 and 128 ACU, and min_capacity must be <= max_capacity."
  }
}

variable "instance_count" {
  description = "Number of Aurora instances in this region"
  type        = number
  default     = 2
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default =   null
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

variable "port" {
  description = "Aurora PostgreSQL port"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
