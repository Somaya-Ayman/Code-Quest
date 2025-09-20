# =============================================================================
# Development Environment Configuration
# =============================================================================

environment = "dev"
aws_region  = "us-west-2"

# =============================================================================
# Development-specific overrides
# =============================================================================

# Smaller instance sizes for cost optimization
node_instance_types     = ["t3.small"]
node_group_min_size     = 1
node_group_max_size     = 3
node_group_desired_size = 1

# Smaller database for development
rds_instance_class      = "db.t3.micro"
rds_allocated_storage   = 20

# Shorter backup retention for dev
backup_retention_period = 1

# Disable deletion protection for easier cleanup
enable_deletion_protection = false

# Enable spot instances for cost savings
enable_spot_instances = true

# Single NAT gateway to save costs
single_nat_gateway = true
