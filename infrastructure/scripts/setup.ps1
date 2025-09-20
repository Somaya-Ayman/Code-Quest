# =============================================================================
# Code Quest Infrastructure Setup Script (Windows PowerShell)
# =============================================================================

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check AWS credentials
function Test-AwsCredentials {
    Write-Status "Checking AWS credentials..."
    try {
        $result = aws sts get-caller-identity 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "AWS credentials are configured"
            Write-Host $result
        } else {
            Write-Error "AWS credentials not configured"
            Write-Status "Please run 'aws configure' first"
            exit 1
        }
    }
    catch {
        Write-Error "AWS credentials not configured"
        Write-Status "Please run 'aws configure' first"
        exit 1
    }
}

# Function to check Docker
function Test-Docker {
    Write-Status "Checking Docker installation..."
    if (Test-Command "docker") {
        Write-Success "Docker is installed"
        docker --version
    } else {
        Write-Error "Docker is not installed"
        Write-Status "Please install Docker Desktop first: https://docs.docker.com/desktop/windows/"
        exit 1
    }
}

# Function to check Docker Compose
function Test-DockerCompose {
    Write-Status "Checking Docker Compose installation..."
    if (Test-Command "docker-compose") {
        Write-Success "Docker Compose is installed"
        docker-compose --version
    } else {
        Write-Error "Docker Compose is not installed"
        Write-Status "Please install Docker Compose first: https://docs.docker.com/compose/install/"
        exit 1
    }
}

# Function to check Make
function Test-Make {
    Write-Status "Checking Make installation..."
    if (Test-Command "make") {
        Write-Success "Make is installed"
        make --version | Select-Object -First 1
    } else {
        Write-Warning "Make is not installed (optional but recommended)"
        Write-Status "You can still use docker-compose commands directly"
        Write-Status "To install Make on Windows:"
        Write-Status "  - Install Chocolatey: https://chocolatey.org/install"
        Write-Status "  - Run: choco install make"
    }
}

# Function to setup environment file
function Set-EnvFile {
    Write-Status "Setting up environment file..."
    if (-not (Test-Path ".env")) {
        if (Test-Path "env.example") {
            Copy-Item "env.example" ".env"
            Write-Success "Created .env file from env.example"
            Write-Warning "Please edit .env file with your configuration"
        } else {
            Write-Warning "env.example not found, creating basic .env file"
            @"
# Code Quest Infrastructure Environment Variables
AWS_PROFILE=default
AWS_REGION=us-west-2
ENVIRONMENT=dev
OWNER=devops-team
"@ | Out-File -FilePath ".env" -Encoding UTF8
            Write-Success "Created basic .env file"
        }
    } else {
        Write-Success ".env file already exists"
    }
}

# Function to setup AWS credentials
function Set-AwsCredentials {
    Write-Status "Setting up AWS credentials..."
    $awsDir = "$env:USERPROFILE\.aws"
    if (-not (Test-Path $awsDir)) {
        Write-Status "Creating AWS credentials directory..."
        New-Item -ItemType Directory -Path $awsDir -Force | Out-Null
    }

    if (-not (Test-Path "$awsDir\credentials")) {
        Write-Warning "AWS credentials file not found"
        Write-Status "Please run 'aws configure' to set up your credentials"
        Write-Status "Or manually create $awsDir\credentials with your access keys"
    } else {
        Write-Success "AWS credentials file exists"
    }
}

# Function to test Docker setup
function Test-DockerSetup {
    Write-Status "Testing Docker setup..."
    try {
        docker-compose config | Out-Null
        Write-Success "Docker Compose configuration is valid"
    }
    catch {
        Write-Error "Docker Compose configuration is invalid"
        exit 1
    }
}

# Function to show next steps
function Show-NextSteps {
    Write-Success "Setup completed successfully!"
    Write-Host ""
    Write-Status "Next steps:"
    Write-Host "1. Edit .env file with your configuration:"
    Write-Host "   notepad .env"
    Write-Host ""
    Write-Host "2. Plan infrastructure deployment:"
    Write-Host "   make plan"
    Write-Host "   # or"
    Write-Host "   docker-compose run --rm terraform-plan"
    Write-Host ""
    Write-Host "3. Apply infrastructure:"
    Write-Host "   make apply"
    Write-Host "   # or"
    Write-Host "   docker-compose run --rm terraform-apply"
    Write-Host ""
    Write-Host "4. Get cluster information:"
    Write-Host "   make cluster-info"
    Write-Host "   # or"
    Write-Host "   docker-compose run --rm aws-cli"
    Write-Host ""
    Write-Host "5. Access Kubernetes cluster:"
    Write-Host "   make kubectl"
    Write-Host "   # or"
    Write-Host "   docker-compose run --rm kubectl"
    Write-Host ""
    Write-Status "For more commands, run: make help"
}

# Main setup function
function Main {
    Write-Status "Starting Code Quest Infrastructure Setup..."
    Write-Host ""

    # Check prerequisites
    Test-Docker
    Test-DockerCompose
    Test-Make
    Test-AwsCredentials

    Write-Host ""

    # Setup files
    Set-EnvFile
    Set-AwsCredentials

    Write-Host ""

    # Test setup
    Test-DockerSetup

    Write-Host ""

    # Show next steps
    Show-NextSteps
}

# Run main function
Main
