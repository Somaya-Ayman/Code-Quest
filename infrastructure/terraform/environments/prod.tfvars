# =============================================================================
# Production Environment Configuration
# =============================================================================

environment = "prod"
aws_region  = "us-east-1"  # Different region for production

# =============================================================================
# Production-specific overrides
# =============================================================================

# Larger instance sizes for production workloads
node_instance_types     = ["t3.medium", "t3.large"]
node_group_min_size     = 2
node_group_max_size     = 20
node_group_desired_size = 3

# Production-grade database
rds_instance_class      = "db.t3.small"
rds_allocated_storage   = 100

# Longer backup retention for production
backup_retention_period = 30

# Enable deletion protection for production
enable_deletion_protection = true

# Disable spot instances for production stability
enable_spot_instances = false

# Multiple NAT gateways for high availability
single_nat_gateway = false

# =============================================================================
# Production Security
# =============================================================================

# Enable encryption
enable_encryption = true

# Restrict access to specific CIDR blocks
allowed_cidr_blocks = [
  "10.0.0.0/8",      # Corporate network
  "172.16.0.0/12",   # Private networks
  "192.168.0.0/16"   # Private networks
]
