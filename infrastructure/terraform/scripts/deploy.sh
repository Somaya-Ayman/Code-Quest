#!/bin/bash

# =============================================================================
# Code Quest Infrastructure Deployment Script
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
REGION="us-west-2"
ACTION="plan"
AUTO_APPROVE=""

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Environment (dev, staging, prod) [default: dev]"
    echo "  -r, --region REGION      AWS region [default: us-west-2]"
    echo "  -a, --action ACTION      Action (plan, apply, destroy) [default: plan]"
    echo "  -y, --yes                Auto-approve apply/destroy operations"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev -a plan                    # Plan dev environment"
    echo "  $0 -e prod -a apply -y               # Apply prod environment with auto-approve"
    echo "  $0 -e dev -a destroy -y              # Destroy dev environment"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -y|--yes)
            AUTO_APPROVE="-auto-approve"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    print_error "Invalid action: $ACTION. Must be plan, apply, or destroy."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

print_status "Starting Code Quest infrastructure deployment..."
print_status "Environment: $ENVIRONMENT"
print_status "Region: $REGION"
print_status "Action: $ACTION"

# Set environment-specific variables
TF_VAR_environment="$ENVIRONMENT"
TF_VAR_aws_region="$REGION"

# Export environment variables
export TF_VAR_environment
export TF_VAR_aws_region

# Change to terraform directory
cd "$(dirname "$0")/.."

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Select workspace
WORKSPACE_NAME="code-quest-$ENVIRONMENT"
print_status "Selecting workspace: $WORKSPACE_NAME"
terraform workspace select "$WORKSPACE_NAME" 2>/dev/null || terraform workspace new "$WORKSPACE_NAME"

# Load environment-specific variables
ENV_FILE="environments/$ENVIRONMENT.tfvars"
if [[ -f "$ENV_FILE" ]]; then
    print_status "Loading environment variables from $ENV_FILE"
    TF_VAR_FILE="-var-file=$ENV_FILE"
else
    print_warning "Environment file $ENV_FILE not found. Using default values."
    TF_VAR_FILE=""
fi

# Execute Terraform command
case $ACTION in
    plan)
        print_status "Planning infrastructure changes..."
        terraform plan $TF_VAR_FILE
        ;;
    apply)
        print_status "Applying infrastructure changes..."
        terraform apply $TF_VAR_FILE $AUTO_APPROVE
        
        if [[ $? -eq 0 ]]; then
            print_success "Infrastructure deployed successfully!"
            print_status "Getting cluster information..."
            
            # Get cluster name
            CLUSTER_NAME=$(terraform output -raw cluster_id 2>/dev/null || echo "unknown")
            
            print_status "EKS Cluster: $CLUSTER_NAME"
            print_status "Region: $REGION"
            print_status "To configure kubectl, run:"
            echo "  aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME"
            
            # Get application URL if available
            APP_URL=$(terraform output -raw application_url 2>/dev/null || echo "not available")
            if [[ "$APP_URL" != "not available" ]]; then
                print_status "Application URL: $APP_URL"
            fi
        fi
        ;;
    destroy)
        print_warning "This will destroy all infrastructure in the $ENVIRONMENT environment!"
        if [[ -z "$AUTO_APPROVE" ]]; then
            read -p "Are you sure you want to continue? (yes/no): " confirm
            if [[ "$confirm" != "yes" ]]; then
                print_status "Destroy cancelled."
                exit 0
            fi
        fi
        
        print_status "Destroying infrastructure..."
        terraform destroy $TF_VAR_FILE $AUTO_APPROVE
        
        if [[ $? -eq 0 ]]; then
            print_success "Infrastructure destroyed successfully!"
        fi
        ;;
esac

print_success "Deployment script completed!"
