# Code Quest Infrastructure - Terraform

This directory contains the Terraform configuration for deploying the Code Quest application infrastructure on AWS.

## 🏗️ Architecture Overview

The infrastructure includes:
- **EKS Cluster** with managed node groups
- **RDS PostgreSQL** database
- **Application Load Balancer** for ingress
- **VPC** with public/private subnets
- **S3 Bucket** for application data
- **IAM Roles** and security policies
- **KMS** encryption keys

## 📁 Directory Structure

```
infrastructure/terraform/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider and Terraform version constraints
├── terraform.tfvars          # Default variable values
├── environments/              # Environment-specific configurations
│   ├── dev.tfvars            # Development environment
│   └── prod.tfvars           # Production environment
├── modules/                   # Reusable Terraform modules
│   └── eks-addons/           # EKS add-ons (ALB Controller, Autoscaler, etc.)
└── scripts/                   # Deployment scripts
    └── deploy.sh              # Automated deployment script
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **kubectl** for Kubernetes management
4. **AWS IAM permissions** for EKS, RDS, VPC, and S3

### Required IAM Permissions

Your AWS user/role needs the following permissions:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonRDSFullAccess`
- `AmazonVPCFullAccess`
- `AmazonS3FullAccess`
- `IAMFullAccess`

### Deployment Steps

1. **Clone and navigate to the terraform directory:**
   ```bash
   cd infrastructure/terraform
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Plan the deployment:**
   ```bash
   # For development
   ./scripts/deploy.sh -e dev -a plan
   
   # For production
   ./scripts/deploy.sh -e prod -a plan
   ```

4. **Apply the infrastructure:**
   ```bash
   # For development
   ./scripts/deploy.sh -e dev -a apply -y
   
   # For production
   ./scripts/deploy.sh -e prod -a apply -y
   ```

5. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name code-quest-dev
   ```

## 🔧 Configuration

### Environment Variables

The following environment variables can be set:

```bash
export TF_VAR_environment="dev"
export TF_VAR_aws_region="us-west-2"
export TF_VAR_owner="your-team"
```

### Customizing Variables

1. **Edit terraform.tfvars** for default values
2. **Edit environments/*.tfvars** for environment-specific overrides
3. **Use -var-file** flag for custom configurations

### Backend Configuration

To use S3 backend for state management, uncomment and configure in `versions.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "code-quest/terraform.tfstate"
  region         = "us-west-2"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

## 🌍 Environment Configurations

### Development Environment
- **Instance Types**: t3.small
- **Node Count**: 1-3 nodes
- **Database**: db.t3.micro
- **Cost Optimization**: Single NAT Gateway, Spot instances enabled

### Production Environment
- **Instance Types**: t3.medium, t3.large
- **Node Count**: 2-20 nodes
- **Database**: db.t3.small
- **High Availability**: Multiple NAT Gateways, Deletion protection enabled

## 📊 Cost Estimation

### Development Environment
- EKS Cluster: ~$73/month
- EC2 Nodes (2x t3.small): ~$60/month
- RDS (db.t3.micro): ~$15/month
- Load Balancer: ~$18/month
- **Total**: ~$166/month

### Production Environment
- EKS Cluster: ~$73/month
- EC2 Nodes (3x t3.medium): ~$90/month
- RDS (db.t3.small): ~$30/month
- Load Balancer: ~$18/month
- **Total**: ~$211/month

## 🔒 Security Features

- **Encryption at Rest**: KMS keys for EKS and RDS
- **Network Security**: Private subnets for database, security groups
- **IAM Roles**: Least privilege access for services
- **VPC**: Isolated network environment
- **Secrets Management**: Environment variables for sensitive data

## 🛠️ Management Commands

### View Infrastructure Status
```bash
terraform show
terraform output
```

### Update Infrastructure
```bash
terraform plan
terraform apply
```

### Destroy Infrastructure
```bash
# Development
./scripts/deploy.sh -e dev -a destroy -y

# Production (be careful!)
./scripts/deploy.sh -e prod -a destroy -y
```

### Access Cluster
```bash
# Get cluster info
aws eks describe-cluster --name code-quest-dev --region us-west-2

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name code-quest-dev

# Verify cluster access
kubectl get nodes
kubectl get pods -A
```

## 🔍 Troubleshooting

### Common Issues

1. **Terraform State Lock**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **AWS Credentials**
   ```bash
   aws configure
   aws sts get-caller-identity
   ```

3. **Kubectl Access**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name code-quest-dev
   kubectl get nodes
   ```

4. **Resource Limits**
   - Check AWS service limits
   - Verify IAM permissions
   - Check region availability

### Useful Commands

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_eks_cluster.main

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Refresh state
terraform refresh
```

## 📚 Next Steps

After infrastructure deployment:

1. **Deploy Application**: Use Kubernetes manifests or Helm charts
2. **Configure Monitoring**: Set up Prometheus, Grafana, and logging
3. **Set up CI/CD**: Configure GitHub Actions for automated deployment
4. **Security Hardening**: Implement network policies, RBAC, and secrets management
5. **Backup Strategy**: Configure RDS backups and disaster recovery

## 🤝 Contributing

1. Make changes to Terraform files
2. Test with `terraform plan`
3. Apply changes with `terraform apply`
4. Update documentation as needed

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Check Terraform documentation
4. Create an issue in the repository
