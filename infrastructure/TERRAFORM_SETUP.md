# 🏗️ Terraform Infrastructure Setup Guide

## 📚 **What We're Building - Infrastructure as Code**

Think of Terraform like a blueprint for your cloud infrastructure. Instead of manually clicking through AWS console to create servers, databases, and networks, we write code that describes exactly what we want, and Terraform builds it for us.

## 🎯 **Infrastructure Overview**

### **What We're Creating:**
1. **VPC (Virtual Private Cloud)** - Our own private network in AWS
2. **EKS Cluster** - Managed Kubernetes cluster for running our application
3. **RDS Database** - Managed PostgreSQL database
4. **Load Balancer** - Distributes traffic to our application
5. **S3 Bucket** - Storage for application data
6. **Security Groups** - Firewall rules for network security
7. **IAM Roles** - Permissions for services to access each other

### **Why This Architecture?**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   Load Balancer │    │   EKS Cluster   │
│   (Users)       │◄──►│   (ALB)         │◄──►│   (Kubernetes)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                       ┌─────────────────┐              │
                       │   RDS Database  │◄─────────────┘
                       │   (PostgreSQL)  │
                       └─────────────────┘
```

## 🔧 **Terraform Files Explained**

### **1. main.tf - The Main Configuration**
This is like the "master blueprint" that defines all our infrastructure:

```hcl
# VPC Module - Creates our private network
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # ... configuration
}

# EKS Module - Creates our Kubernetes cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  # ... configuration
}

# RDS Module - Creates our database
module "rds" {
  source = "terraform-aws-modules/rds/aws"
  # ... configuration
}
```

**Key Concepts:**
- **Modules**: Reusable components (like LEGO blocks)
- **Resources**: Individual AWS services (EC2, RDS, etc.)
- **Dependencies**: Some resources depend on others (database needs VPC first)

### **2. variables.tf - Configuration Parameters**
Think of this as the "settings" file where we define what can be customized:

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}
```

**Why Variables?**
- **Flexibility**: Same code, different environments
- **Reusability**: One template, multiple deployments
- **Security**: Sensitive values can be passed securely

### **3. outputs.tf - What We Get Back**
This tells us what was created and how to access it:

```hcl
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}
```

**Why Outputs?**
- **Connection Info**: How to connect to our services
- **Documentation**: What was actually created
- **Integration**: Other systems can use these values

### **4. terraform.tfvars - Default Values**
This is where we set our default configuration:

```hcl
environment = "dev"
aws_region  = "us-west-2"
node_group_desired_size = 2
```

## 🌍 **Environment-Specific Configurations**

### **Development Environment (dev.tfvars)**
```hcl
# Smaller, cheaper resources for development
node_instance_types = ["t3.small"]
node_group_desired_size = 1
rds_instance_class = "db.t3.micro"
enable_spot_instances = true  # Save money with spot instances
```

### **Production Environment (prod.tfvars)**
```hcl
# Larger, more reliable resources for production
node_instance_types = ["t3.medium", "t3.large"]
node_group_desired_size = 3
rds_instance_class = "db.t3.small"
enable_deletion_protection = true  # Prevent accidental deletion
```

## 🚀 **Step-by-Step Deployment**

### **Step 1: Prerequisites**
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Configure AWS credentials
aws configure
```

### **Step 2: Deploy Infrastructure**
```bash
# Navigate to terraform directory
cd infrastructure/terraform

# Initialize Terraform (downloads providers and modules)
terraform init

# Plan the deployment (shows what will be created)
terraform plan -var-file="environments/dev.tfvars"

# Apply the infrastructure (actually creates it)
terraform apply -var-file="environments/dev.tfvars"
```

### **Step 3: Verify Deployment**
```bash
# Check what was created
terraform output

# Configure kubectl to access the cluster
aws eks update-kubeconfig --region us-west-2 --name code-quest-dev

# Verify cluster access
kubectl get nodes
kubectl get pods -A
```

## 🔒 **Security Features Explained**

### **1. Network Security**
```hcl
# Security groups act like firewalls
resource "aws_security_group" "rds" {
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]  # Only allow traffic from our VPC
  }
}
```

**What this does:**
- Database only accepts connections from our VPC
- No direct internet access to database
- Load balancer handles external traffic

### **2. IAM Roles and Permissions**
```hcl
# EKS nodes get specific permissions
resource "aws_iam_role" "eks_node_role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
```

**Why this matters:**
- **Least Privilege**: Services only get permissions they need
- **No Hardcoded Keys**: Uses IAM roles instead of access keys
- **Automatic Rotation**: AWS manages the credentials

### **3. Encryption**
```hcl
# KMS key for encrypting sensitive data
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  enable_key_rotation     = true
}
```

**Security Benefits:**
- **Data at Rest**: All data encrypted in database and storage
- **Key Rotation**: Encryption keys automatically rotate
- **Access Control**: Only authorized services can decrypt data

## 💰 **Cost Optimization Strategies**

### **Development Environment**
```hcl
# Use smaller instances
node_instance_types = ["t3.small"]

# Enable spot instances (up to 90% cheaper)
enable_spot_instances = true

# Single NAT gateway (instead of one per AZ)
single_nat_gateway = true

# Smaller database
rds_instance_class = "db.t3.micro"
```

### **Production Environment**
```hcl
# Use appropriate instance sizes
node_instance_types = ["t3.medium", "t3.large"]

# Reserved instances for predictable workloads
# (configured outside Terraform)

# Multiple AZs for high availability
single_nat_gateway = false
```

## 🔍 **Understanding Terraform State**

### **What is State?**
Terraform keeps track of what it created in a "state file":
```json
{
  "resources": [
    {
      "type": "aws_instance",
      "name": "web",
      "instances": [
        {
          "attributes": {
            "id": "i-1234567890abcdef0",
            "ami": "ami-0c02fb55956c7d316"
          }
        }
      ]
    }
  ]
}
```

### **Why State Matters:**
- **Change Detection**: Knows what changed since last run
- **Dependency Management**: Understands resource relationships
- **Resource Updates**: Can modify existing resources
- **Cleanup**: Knows what to destroy when you run `terraform destroy`

## 🛠️ **Common Terraform Commands**

### **Basic Commands**
```bash
# Initialize (download providers and modules)
terraform init

# Plan (show what will change)
terraform plan

# Apply (make the changes)
terraform apply

# Destroy (remove everything)
terraform destroy
```

### **Advanced Commands**
```bash
# Show current state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Refresh state from AWS
terraform refresh
```

## 🚨 **Troubleshooting Common Issues**

### **1. State Lock Issues**
```bash
# If someone else is running Terraform
terraform force-unlock <lock-id>

# Check who has the lock
terraform plan
```

### **2. Resource Already Exists**
```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Or remove from state if not needed
terraform state rm aws_instance.web
```

### **3. Permission Issues**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name your-username
```

### **4. Module Issues**
```bash
# Update modules
terraform init -upgrade

# Clean module cache
rm -rf .terraform/modules
terraform init
```

## 📊 **Monitoring Your Infrastructure**

### **AWS Console**
- **EC2 Dashboard**: View instances and their status
- **EKS Console**: Monitor cluster health and nodes
- **RDS Console**: Check database performance and backups
- **CloudWatch**: View logs and metrics

### **Terraform Outputs**
```bash
# Get all outputs
terraform output

# Get specific output
terraform output cluster_endpoint
terraform output database_endpoint
```

### **Cost Monitoring**
- **AWS Cost Explorer**: Track spending over time
- **AWS Budgets**: Set up alerts for cost overruns
- **Resource Tagging**: Track costs by environment/project

## 🎓 **Key Learning Points**

### **Infrastructure as Code Benefits:**
1. **Version Control**: Track changes to infrastructure
2. **Reproducibility**: Same infrastructure every time
3. **Collaboration**: Team can review and approve changes
4. **Documentation**: Code is self-documenting
5. **Testing**: Can test infrastructure changes safely

### **Terraform Best Practices:**
1. **Use Modules**: Don't repeat yourself
2. **Variable Everything**: Make it configurable
3. **State Management**: Use remote state storage
4. **Resource Naming**: Use consistent naming conventions
5. **Documentation**: Comment your code

### **AWS Best Practices:**
1. **Least Privilege**: Only give necessary permissions
2. **Multi-AZ**: Deploy across availability zones
3. **Encryption**: Encrypt data at rest and in transit
4. **Monitoring**: Set up logging and alerting
5. **Backup**: Regular backups and disaster recovery

This infrastructure gives you a solid foundation for running your application in the cloud with proper security, scalability, and cost optimization. The next step would be to deploy your application using Kubernetes manifests or Helm charts!
