variable "project" {
  type        = string
  description = "项目名，用于命名与标签"
}

variable "env" {
  type        = string
  description = "环境名（dev/stage/prod 等）"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID（用于创建 RDS 安全组）"
}

variable "database_subnets" {
  type        = list(string)
  description = "数据库子网（通常来自 module.vpc.database_subnets）"
}

variable "engine" {
  type        = string
  description = "数据库引擎，如 mysql、postgres"
  default     = "mysql"
}

variable "instance_class" {
  type        = string
  description = "RDS 实例规格，如 db.t3.medium"
  default     = "db.t3.medium"
}

variable "db_name" {
  type        = string
  description = "初始化数据库名（Postgres 可选；MySQL 必填时指定）"
  default     = "appdb"
}

variable "db_master_username" {
  type        = string
  description = "主用户"
  default     = "adminuser"
}

variable "db_master_password" {
  type        = string
  description = "主用户密码（建议通过 TF var/CI secret 注入）"
  sensitive   = true
}

variable "port" {
  type        = number
  description = "数据库端口（MySQL 默认 3306 / Postgres 5432）"
  default     = 3306
}

variable "allocated_storage" {
  type        = number
  description = "初始存储（GB）"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "最大自动扩容（GB）；0 表示关闭"
  default     = 100
}

variable "multi_az" {
  type        = bool
  description = "是否多可用区"
  default     = true
}

variable "storage_encrypted" {
  type        = bool
  description = "是否开启存储加密（建议开启）"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "自定义 KMS Key（为空则用 AWS 默认 RDS KMS）"
  default     = null
}

variable "backup_retention_period" {
  type        = number
  description = "备份保留天数"
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "备份时间窗（UTC）"
  default     = "19:00-21:00"
}

variable "maintenance_window" {
  type        = string
  description = "维护时间窗（UTC）"
  default     = "sun:22:00-sun:23:00"
}

variable "deletion_protection" {
  type        = bool
  description = "防删除保护"
  default     = true
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "允许主版本升级（需谨慎）"
  default     = false
}

variable "monitoring_interval" {
  type        = number
  description = "Enhanced monitoring（秒，0 关闭）"
  default     = 0
}

variable "performance_insights_enabled" {
  type        = bool
  description = "开启 Performance Insights"
  default     = false
}

variable "performance_insights_kms_key_id" {
  type        = string
  description = "PI 的 KMS Key（启用时可指定）"
  default     = null
}

variable "parameter_group_family" {
  type        = string
  description = "参数组 family（MySQL 例：mysql8.0；Postgres 例：postgres16）"
  default     = "mysql8.0"
}

variable "parameters" {
  description = "可选：参数组自定义参数列表"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "apply_immediately" {
  type        = bool
  description = "是否立即应用（true 可能导致小抖动）"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "额外标签"
  default     = {}
}

# Replace the list variable with a map
variable "allowed_sg_ids" {
  description = "Map of allowed SGs (use stable keys)"
  type        = map(string)
  default     = {}
}

variable "engine_version" {
  type        = string
  description = "Optional engine version; if null, use AWS default for the family."
  default     = null
}
