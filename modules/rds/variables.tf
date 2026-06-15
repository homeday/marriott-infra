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
}

variable "instance_count" {
  description = "Number of Aurora instances in this region"
  type        = number
  default     = 1
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
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
