# 🐳 Docker Compose Terraform Setup Guide

## 📚 **What We're Building - Containerized Infrastructure Management**

Instead of installing Terraform, AWS CLI, and kubectl on your local machine, we're using Docker containers to run all these tools. This ensures:
- **Consistent Environment**: Same tools and versions for everyone
- **No Local Dependencies**: No need to install anything except Docker
- **Isolated Workspace**: Each project has its own containerized environment
- **Easy Cleanup**: Just remove containers when done

## 🏗️ **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Host (Your Machine)              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │  Terraform      │  │  AWS CLI        │  │  Kubectl    │  │
│  │  Container      │  │  Container      │  │  Container  │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
│           │                    │                    │        │
│           └────────────────────┼────────────────────┘        │
│                                │                             │
│  ┌─────────────────────────────┴─────────────────────────┐  │
│  │              AWS Cloud (EKS, RDS, VPC)                │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 **Quick Start**

### **Prerequisites**
1. **Docker** installed and running
2. **Docker Compose** installed
3. **AWS credentials** configured

### **Setup Steps**

1. **Clone and navigate to infrastructure directory:**
   ```bash
   cd infrastructure
   ```

2. **Run the setup script:**
   ```bash
   # On Linux/Mac
   ./scripts/setup.sh
   
   # On Windows (PowerShell)
   bash scripts/setup.sh
   ```

3. **Configure environment:**
   ```bash
   # Copy example environment file
   cp env.example .env
   
   # Edit with your settings
   nano .env
   ```

4. **Deploy infrastructure:**
   ```bash
   # Using Make (recommended)
   make plan
   make apply
   
   # Or using Docker Compose directly
   docker-compose run --rm terraform-plan
   docker-compose run --rm terraform-apply
   ```

## 🔧 **Available Services**

### **1. Terraform Services**

#### **terraform-plan**
```bash
# Plan infrastructure changes
docker-compose run --rm terraform-plan ENVIRONMENT=dev
```

#### **terraform-apply**
```bash
# Apply infrastructure changes
docker-compose run --rm terraform-apply ENVIRONMENT=dev
```

#### **terraform-destroy**
```bash
# Destroy infrastructure
docker-compose run --rm terraform-destroy ENVIRONMENT=dev
```

### **2. Utility Services**

#### **aws-cli**
```bash
# AWS CLI shell
docker-compose run --rm aws-cli ENVIRONMENT=dev
```

#### **kubectl**
```bash
# Kubernetes CLI shell
docker-compose run --rm kubectl ENVIRONMENT=dev
```

#### **terraform-state**
```bash
# Terraform state management
docker-compose run --rm terraform-state ENVIRONMENT=dev
```

### **3. Environment Shells**

#### **dev-environment**
```bash
# Development environment shell
docker-compose run --rm dev-environment
```

#### **prod-environment**
```bash
# Production environment shell
docker-compose run --rm prod-environment
```

## 🛠️ **Using Make Commands (Recommended)**

### **Basic Operations**
```bash
# Plan infrastructure
make plan

# Apply infrastructure
make apply

# Destroy infrastructure
make destroy

# Show help
make help
```

### **Environment-Specific Operations**
```bash
# Development environment
make plan ENVIRONMENT=dev
make apply ENVIRONMENT=dev

# Production environment
make plan ENVIRONMENT=prod
make apply ENVIRONMENT=prod
```

### **Utility Commands**
```bash
# AWS CLI shell
make aws

# Kubernetes shell
make kubectl

# Terraform state management
make state

# Show infrastructure status
make status

# Clean up containers
make clean
```

## 🔍 **Understanding the Docker Compose Configuration**

### **Service Structure**
```yaml
services:
  terraform:
    image: hashicorp/terraform:1.6.0  # Official Terraform image
    working_dir: /workspace           # Working directory in container
    volumes:
      - ./terraform:/workspace        # Mount terraform directory
      - ~/.aws:/root/.aws:ro          # Mount AWS credentials (read-only)
    environment:
      - TF_VAR_environment=${ENVIRONMENT:-dev}  # Environment variables
    command: terraform plan            # Command to run
```

### **Volume Mounts Explained**
- **`./terraform:/workspace`**: Your terraform files are available in the container
- **`~/.aws:/root/.aws:ro`**: AWS credentials are available (read-only for security)
- **`terraform-cache:/root/.terraform.d`**: Terraform modules and providers are cached

### **Environment Variables**
- **`TF_VAR_environment`**: Sets the environment (dev/prod)
- **`TF_VAR_aws_region`**: Sets the AWS region
- **`AWS_PROFILE`**: Sets the AWS profile to use

## 🔒 **Security Features**

### **1. Read-Only Credentials**
```yaml
volumes:
  - ~/.aws:/root/.aws:ro  # Read-only mount prevents accidental modification
```

### **2. Isolated Containers**
- Each service runs in its own container
- No persistent data stored in containers
- Easy cleanup and reset

### **3. Environment Isolation**
- Different containers for different environments
- Separate AWS profiles and regions
- No cross-environment contamination

## 💰 **Cost Management**

### **Development Environment**
```bash
# Use smaller instances
ENVIRONMENT=dev make apply

# Enable spot instances for cost savings
# (configured in environments/dev.tfvars)
```

### **Production Environment**
```bash
# Use production-grade instances
ENVIRONMENT=prod make apply

# High availability configuration
# (configured in environments/prod.tfvars)
```

## 🔍 **Troubleshooting**

### **Common Issues**

#### **1. AWS Credentials Not Found**
```bash
# Check if credentials exist
ls ~/.aws/credentials

# Configure if missing
aws configure
```

#### **2. Docker Not Running**
```bash
# Start Docker service
sudo systemctl start docker  # Linux
# Or start Docker Desktop on Windows/Mac
```

#### **3. Permission Issues**
```bash
# Fix file permissions
chmod +x scripts/setup.sh
chmod +x scripts/deploy.sh
```

#### **4. Container Not Starting**
```bash
# Check logs
docker-compose logs terraform

# Check configuration
docker-compose config
```

### **Debug Commands**
```bash
# Start debug shell with all tools
make debug

# Show container logs
make logs

# Check infrastructure status
make status
```

## 📊 **Monitoring and Management**

### **View Infrastructure Status**
```bash
# Show all outputs
make output

# Show cluster information
make cluster-info

# Check AWS resources
make aws
```

### **Access Kubernetes Cluster**
```bash
# Start kubectl shell
make kubectl

# Inside the shell:
kubectl get nodes
kubectl get pods -A
kubectl get services
```

### **Terraform State Management**
```bash
# Start state management shell
make state

# Inside the shell:
terraform state list
terraform state show aws_eks_cluster.main
terraform output
```

## 🚀 **Complete Workflow Examples**

### **Development Workflow**
```bash
# 1. Setup
cd infrastructure
cp env.example .env
# Edit .env with your settings

# 2. Plan
make plan ENVIRONMENT=dev

# 3. Apply
make apply ENVIRONMENT=dev

# 4. Verify
make cluster-info ENVIRONMENT=dev
make kubectl ENVIRONMENT=dev
```

### **Production Workflow**
```bash
# 1. Plan production
make plan ENVIRONMENT=prod

# 2. Apply production
make apply ENVIRONMENT=prod

# 3. Verify production
make cluster-info ENVIRONMENT=prod
```

### **Cleanup Workflow**
```bash
# 1. Destroy infrastructure
make destroy ENVIRONMENT=dev

# 2. Clean up containers
make clean

# 3. Clean up everything
make clean-all
```

## 🎓 **Key Learning Points**

### **Docker Compose Benefits:**
1. **Consistency**: Same environment for all team members
2. **Isolation**: Each project has its own containerized environment
3. **Portability**: Works on any machine with Docker
4. **Version Control**: Specific tool versions in containers
5. **Easy Cleanup**: Remove containers when done

### **Infrastructure as Code Benefits:**
1. **Version Control**: Track changes to infrastructure
2. **Reproducibility**: Same infrastructure every time
3. **Collaboration**: Team can review and approve changes
4. **Documentation**: Code is self-documenting
5. **Testing**: Can test infrastructure changes safely

### **Best Practices:**
1. **Use Make Commands**: Easier than remembering Docker Compose syntax
2. **Environment Files**: Use .env for configuration
3. **Regular Cleanup**: Clean up containers and volumes regularly
4. **Backup State**: Use remote state storage for production
5. **Monitor Costs**: Keep track of AWS resource usage

This Docker Compose setup makes it easy to manage your infrastructure without installing any tools locally. Everything runs in containers, ensuring consistency and easy cleanup!
