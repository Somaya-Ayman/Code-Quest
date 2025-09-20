# =============================================================================
# Terraform Variables for Code Quest Infrastructure
# =============================================================================

# =============================================================================
# General Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "code-quest"
}

# =============================================================================
# Networking Configuration
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

# =============================================================================
# EKS Configuration
# =============================================================================

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 10
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "Disk size for EKS nodes in GB"
  type        = number
  default     = 50
}

variable "enable_taints" {
  description = "Enable taints on EKS nodes"
  type        = bool
  default     = false
}

# =============================================================================
# RDS Configuration
# =============================================================================

variable "postgres_version" {
  description = "PostgreSQL version for RDS"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "todoapp"
}

variable "database_username" {
  description = "Username for the database"
  type        = string
  default     = "todoapp"
}

variable "database_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = false
}

# =============================================================================
# Monitoring Configuration
# =============================================================================

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for EKS"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

# =============================================================================
# Security Configuration
# =============================================================================

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_encryption" {
  description = "Enable encryption for EKS cluster"
  type        = bool
  default     = true
}

# =============================================================================
# Cost Optimization
# =============================================================================

variable "enable_spot_instances" {
  description = "Enable spot instances for EKS nodes"
  type        = bool
  default     = false
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = true
}

# =============================================================================
# Application Configuration
# =============================================================================

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "todo-app"
}

variable "app_version" {
  description = "Version of the application"
  type        = string
  default     = "1.0.0"
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 3000
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}

# =============================================================================
# Environment-specific overrides
# =============================================================================

variable "dev_overrides" {
  description = "Development environment specific overrides"
  type        = map(any)
  default = {
    node_group_min_size     = 1
    node_group_max_size     = 3
    node_group_desired_size = 1
    rds_instance_class      = "db.t3.micro"
    rds_allocated_storage   = 20
    backup_retention_period = 1
    enable_deletion_protection = false
  }
}

variable "prod_overrides" {
  description = "Production environment specific overrides"
  type        = map(any)
  default = {
    node_group_min_size     = 2
    node_group_max_size     = 20
    node_group_desired_size = 3
    rds_instance_class      = "db.t3.small"
    rds_allocated_storage   = 100
    backup_retention_period = 30
    enable_deletion_protection = true
  }
}
