# =============================================================================
# Terraform Variables for Code Quest Infrastructure
# =============================================================================

# =============================================================================
# Environment Configuration
# =============================================================================

environment = "dev"
aws_region  = "us-west-2"
owner       = "devops-team"

# =============================================================================
# Cluster Configuration
# =============================================================================

cluster_name        = "code-quest"
kubernetes_version  = "1.28"

# =============================================================================
# Node Group Configuration
# =============================================================================

node_instance_types     = ["t3.medium"]
node_group_min_size     = 1
node_group_max_size     = 5
node_group_desired_size = 2
node_disk_size         = 50

# =============================================================================
# Database Configuration
# =============================================================================

postgres_version        = "15.4"
rds_instance_class      = "db.t3.micro"
rds_allocated_storage   = 20
database_name          = "todoapp"
database_username      = "todoapp"
database_password      = "ChangeMe123!"  # Change this in production!

# =============================================================================
# Security Configuration
# =============================================================================

enable_deletion_protection = false  # Set to true for production
backup_retention_period    = 7

# =============================================================================
# Networking Configuration
# =============================================================================

vpc_cidr            = "10.0.0.0/16"
single_nat_gateway  = true

# =============================================================================
# Cost Optimization
# =============================================================================

enable_spot_instances      = false
enable_cluster_autoscaler  = true
