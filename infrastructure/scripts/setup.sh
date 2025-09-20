#!/bin/bash

# =============================================================================
# Code Quest Infrastructure Setup Script
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check AWS credentials
check_aws_credentials() {
    print_status "Checking AWS credentials..."
    if aws sts get-caller-identity >/dev/null 2>&1; then
        print_success "AWS credentials are configured"
        aws sts get-caller-identity
    else
        print_error "AWS credentials not configured"
        print_status "Please run 'aws configure' first"
        exit 1
    fi
}

# Function to check Docker
check_docker() {
    print_status "Checking Docker installation..."
    if command_exists docker; then
        print_success "Docker is installed"
        docker --version
    else
        print_error "Docker is not installed"
        print_status "Please install Docker first: https://docs.docker.com/get-docker/"
        exit 1
    fi
}

# Function to check Docker Compose
check_docker_compose() {
    print_status "Checking Docker Compose installation..."
    if command_exists docker-compose; then
        print_success "Docker Compose is installed"
        docker-compose --version
    else
        print_error "Docker Compose is not installed"
        print_status "Please install Docker Compose first: https://docs.docker.com/compose/install/"
        exit 1
    fi
}

# Function to check Make
check_make() {
    print_status "Checking Make installation..."
    if command_exists make; then
        print_success "Make is installed"
        make --version | head -n1
    else
        print_warning "Make is not installed (optional but recommended)"
        print_status "You can still use docker-compose commands directly"
    fi
}

# Function to setup environment file
setup_env_file() {
    print_status "Setting up environment file..."
    if [[ ! -f .env ]]; then
        if [[ -f env.example ]]; then
            cp env.example .env
            print_success "Created .env file from env.example"
            print_warning "Please edit .env file with your configuration"
        else
            print_warning "env.example not found, creating basic .env file"
            cat > .env << EOF
# Code Quest Infrastructure Environment Variables
AWS_PROFILE=default
AWS_REGION=us-west-2
ENVIRONMENT=dev
OWNER=devops-team
EOF
            print_success "Created basic .env file"
        fi
    else
        print_success ".env file already exists"
    fi
}

# Function to setup AWS credentials
setup_aws_credentials() {
    print_status "Setting up AWS credentials..."
    if [[ ! -d ~/.aws ]]; then
        print_status "Creating AWS credentials directory..."
        mkdir -p ~/.aws
    fi

    if [[ ! -f ~/.aws/credentials ]]; then
        print_warning "AWS credentials file not found"
        print_status "Please run 'aws configure' to set up your credentials"
        print_status "Or manually create ~/.aws/credentials with your access keys"
    else
        print_success "AWS credentials file exists"
    fi
}

# Function to test Docker setup
test_docker_setup() {
    print_status "Testing Docker setup..."
    if docker-compose config >/dev/null 2>&1; then
        print_success "Docker Compose configuration is valid"
    else
        print_error "Docker Compose configuration is invalid"
        exit 1
    fi
}

# Function to show next steps
show_next_steps() {
    print_success "Setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Edit .env file with your configuration:"
    echo "   nano .env"
    echo ""
    echo "2. Plan infrastructure deployment:"
    echo "   make plan"
    echo "   # or"
    echo "   docker-compose run --rm terraform-plan"
    echo ""
    echo "3. Apply infrastructure:"
    echo "   make apply"
    echo "   # or"
    echo "   docker-compose run --rm terraform-apply"
    echo ""
    echo "4. Get cluster information:"
    echo "   make cluster-info"
    echo "   # or"
    echo "   docker-compose run --rm aws-cli"
    echo ""
    echo "5. Access Kubernetes cluster:"
    echo "   make kubectl"
    echo "   # or"
    echo "   docker-compose run --rm kubectl"
    echo ""
    print_status "For more commands, run: make help"
}

# Main setup function
main() {
    print_status "Starting Code Quest Infrastructure Setup..."
    echo ""

    # Check prerequisites
    check_docker
    check_docker_compose
    check_make
    check_aws_credentials

    echo ""

    # Setup files
    setup_env_file
    setup_aws_credentials

    echo ""

    # Test setup
    test_docker_setup

    echo ""

    # Show next steps
    show_next_steps
}

# Run main function
main "$@"

