# 🚀 Code Quest - DevOps Project

A comprehensive DevOps project demonstrating modern cloud-native application deployment with AWS EKS, Terraform, CI/CD pipelines, and security best practices.

## 📋 Project Overview

**Code Quest** is a 3-tier web application built with modern DevOps practices, featuring:
- **Frontend**: Static HTML served by Python HTTP server
- **Backend**: Node.js Express API with PostgreSQL
- **Infrastructure**: AWS EKS cluster with Terraform
- **Database**: PostgreSQL running as a pod in Kubernetes
- **CI/CD**: GitHub Actions with security scanning
- **Security**: Pod Security Admission, RBAC, and network policies
- **Monitoring**: HPA, health checks, and resource management
- **External Access**: AWS Load Balancers for public access

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud                            │
├─────────────────────────────────────────────────────────┤
│  EKS Cluster (code-quest)                              │
│  ├── Frontend (Python HTTP) - Port 8080                │
│  ├── Backend (Node.js) - Port 3000                     │
│  └── Database (PostgreSQL Pod) - Port 5432             │
├─────────────────────────────────────────────────────────┤
│  Supporting Services                                    │
│  ├── S3 Bucket (App Data)                              │
│  ├── ALB (Load Balancer) - External Access             │
│  └── VPC with Public/Private Subnets                   │
└─────────────────────────────────────────────────────────┘
```

### **Features Available:**
- ✅ **Add Tasks**: Type a task and click "Add Task"
- ✅ **Delete Tasks**: Click the "Delete" button next to any task
- ✅ **Real-time Updates**: Changes are reflected immediately
- ✅ **Health Check**: Visit `/health` endpoint for API status
- ✅ **Responsive Design**: Works on desktop and mobile

## 🚀 Quick Start

### Prerequisites

- **Docker & Docker Compose** - For containerization
- **Node.js 18+** - For local development
- **AWS CLI** - For cloud operations
- **kubectl** - For Kubernetes management
- **Terraform** - For infrastructure management
- **Git** - For version control

### 1. Clone the Repository

```bash
git clone https://github.com/somaya189ayman/Code-Quest.git
cd Code-Quest
```

### 2. Local Development Setup

#### Option A: Docker Compose (Recommended)
```bash
# Start all services locally
docker-compose up --build

# Access the application
# Frontend: http://localhost:8080
# Backend API: http://localhost:3000
# PostgreSQL: localhost:5432
```

#### Option B: Local Development
```bash
# Install dependencies
npm run install-all

# Start PostgreSQL (requires local installation)
# Create database: todoapp
# Username: todoapp, Password: todoapp123

# Start the application
npm run dev
```

### 3. Infrastructure Deployment

#### Prerequisites
```bash
# Configure AWS credentials
aws configure

# Set environment variables
export AWS_REGION=us-west-2
export AWS_PROFILE=default
```

#### Deploy Infrastructure
```bash
# Navigate to infrastructure directory
cd infrastructure

# Plan infrastructure changes
make plan ENVIRONMENT=dev

# Deploy infrastructure
make apply ENVIRONMENT=dev

# Verify deployment
make status ENVIRONMENT=dev
```

### 4. Application Deployment

#### Update kubeconfig
```bash
aws eks update-kubeconfig --region us-west-2 --name code-quest
```

#### Deploy to Kubernetes
```bash
# Deploy all Kubernetes manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n code-quest
kubectl get services -n code-quest
kubectl get ingress -n code-quest
```

## 🛠️ Development Commands

### Local Development
```bash
# Install all dependencies
npm run install-all

# Start development servers
npm run dev

# Start backend only
npm run backend

# Start frontend only
npm run frontend

# Build and start with Docker
docker-compose up --build

# Stop all services
docker-compose down

# View logs
docker-compose logs -f
```

### Infrastructure Management
```bash
# Plan infrastructure changes
make plan ENVIRONMENT=dev

# Apply infrastructure changes
make apply ENVIRONMENT=dev

# Destroy infrastructure
make destroy ENVIRONMENT=dev

# Check infrastructure status
make status ENVIRONMENT=dev

# Access development environment
make dev-environment
```

### Kubernetes Management
```bash
# Get all resources
kubectl get all -n code-quest

# Check pod logs
kubectl logs -l app=frontend -n code-quest
kubectl logs -l app=backend -n code-quest

# Scale deployments
kubectl scale deployment frontend --replicas=5 -n code-quest

# Check HPA status
kubectl get hpa -n code-quest

# Port forward for local access
kubectl port-forward service/frontend 8080:80 -n code-quest
kubectl port-forward service/backend 3000:3000 -n code-quest
```

## 🔧 Configuration

### Environment Variables

#### Backend Configuration
- `DB_HOST`: Database host (default: localhost)
- `DB_PORT`: Database port (default: 5432)
- `DB_NAME`: Database name (default: todoapp)
- `DB_USER`: Database user (default: todoapp)
- `DB_PASSWORD`: Database password (default: todoapp123)
- `NODE_ENV`: Environment (default: production)

#### Infrastructure Configuration
- `AWS_REGION`: AWS region (default: us-west-2)
- `AWS_PROFILE`: AWS profile (default: default)
- `ENVIRONMENT`: Environment name (dev/prod)

### Database Schema
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 📊 API Endpoints

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/health` | Health check | - | `{status: "OK", timestamp: "..."}` |
| GET | `/listTasks` | List all tasks | - | `{tasks: [...]}` |
| POST | `/addTask` | Add new task | `{name: "task name"}` | `{message: "...", task: {...}, tasks: [...]}` |
| DELETE | `/deleteTask` | Delete task | `{id: 1}` | `{message: "...", tasks: [...]}` |

## 🔒 Security Features

### Pod Security Admission (PSA)
- **Enforcement**: Restricted mode for all pods
- **Non-root execution**: All containers run as non-root user
- **Security contexts**: Proper user and group IDs

### Network Security
- **Security Groups**: Restrictive inbound/outbound rules
- **Private Subnets**: Database in private subnets only
- **VPC**: Isolated network environment
- **ALB**: Application Load Balancer with SSL termination

### Secrets Management
- **Kubernetes Secrets**: Database credentials and API keys
- **IAM Roles**: Proper RBAC configuration
- **Image Security**: Trivy vulnerability scanning

## 📈 Monitoring & Scaling

### Horizontal Pod Autoscaler (HPA)
- **Min Replicas**: 2 (high availability)
- **Max Replicas**: 10 (cost optimization)
- **Scaling Metrics**: CPU (70%) and Memory (80%)
- **Scaling Behavior**: Gradual scale-up/down

### Health Checks
- **Liveness Probe**: HTTP health check on `/health`
- **Readiness Probe**: HTTP readiness check
- **Resource Limits**: CPU and memory constraints

### Resource Management
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

## 🚀 CI/CD Pipeline

### Development Pipeline
- **Trigger**: Push to `develop` branch
- **Build**: Docker images for frontend and backend
- **Test**: Automated testing and linting
- **Security**: Trivy vulnerability scanning
- **Deploy**: Automatic deployment to EKS cluster

### Infrastructure Pipeline
- **Trigger**: Push to `main` branch
- **Plan**: Terraform plan for infrastructure changes
- **Apply**: Automated infrastructure deployment
- **Security**: Security scanning and compliance checks

## 🏗️ Project Structure

```
Code-Quest/
├── .github/workflows/          # CI/CD pipelines
│   ├── development.yaml        # Dev deployment pipeline
│   ├── production.yaml         # Prod deployment pipeline
│   └── infrastructure.yml      # Infrastructure pipeline
├── infrastructure/             # Terraform IaC
│   ├── terraform/             # Terraform configurations
│   │   ├── main.tf            # Main infrastructure (no RDS)
│   │   ├── variables.tf       # Input variables
│   │   ├── output.tf          # Output values
│   │   └── environments/      # Environment-specific configs
│   └── docker-compose.yml     # Infrastructure services
├── k8s/                       # Kubernetes manifests
│   ├── namespace.yaml         # Namespace with PSA
│   ├── frontend-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── postgres-deployment.yaml # PostgreSQL pod
│   ├── services.yaml          # ClusterIP services
│   ├── frontend-loadbalancer.yaml # External access
│   ├── backend-loadbalancer.yaml  # External access
│   ├── hpa.yaml              # Horizontal Pod Autoscaler
│   └── ingress.yaml          # ALB ingress
├── frontend/                  # Frontend application
│   ├── Dockerfile
│   └── index.html
├── backend/                   # Backend API
│   ├── Dockerfile
│   ├── package.json
│   └── index.js
├── docker-compose.yml         # Local development
├── PRESENTATION_SCRIPT.md     # Video presentation guide
└── README.md                  # This file
```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure PostgreSQL is running
   - Check environment variables
   - Verify database credentials

2. **Port Already in Use**
   - Check if ports 3000, 8080, or 5432 are available
   - Use `docker-compose down` to stop existing containers

3. **Frontend Can't Connect to Backend**
   - Ensure backend is running on port 3000
   - Check CORS configuration
   - Verify API_BASE URL in frontend

4. **Kubernetes Deployment Issues**
   - Check pod logs: `kubectl logs -l app=backend -n code-quest`
   - Verify image tags: `kubectl describe pod <pod-name> -n code-quest`
   - Check resource limits and requests
   - Verify PostgreSQL pod is running: `kubectl get pods -l app=postgres -n code-quest`

5. **Database Connection Issues**
   - Check PostgreSQL pod status: `kubectl get pods -l app=postgres -n code-quest`
   - Verify database service: `kubectl get svc postgres-service -n code-quest`
   - Check backend logs for connection errors: `kubectl logs -l app=backend -n code-quest`

6. **External Access Issues**
   - Check LoadBalancer services: `kubectl get svc -n code-quest`
   - Verify external IPs are assigned
   - Test connectivity: `curl http://[EXTERNAL-IP]/`

7. **Terraform Issues**
   - Verify AWS credentials: `aws sts get-caller-identity`
   - Check Terraform state: `terraform state list`
   - Validate configuration: `terraform validate`

### Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs backend
docker-compose logs postgres
docker-compose logs frontend

# Follow logs in real-time
docker-compose logs -f

# Kubernetes logs
kubectl logs -l app=frontend -n code-quest
kubectl logs -l app=backend -n code-quest
```

## 📊 Current Deployment Status

### **✅ Fully Deployed and Running**
- **Frontend**: Python HTTP server with external LoadBalancer access
- **Backend**: Node.js API with external LoadBalancer access  
- **Database**: PostgreSQL pod running in Kubernetes cluster
- **Security**: Pod Security Admission (PSA) compliant
- **Scaling**: Horizontal Pod Autoscaler configured
- **Monitoring**: Health checks and resource limits active

### **💰 Cost Optimization**
- **PostgreSQL Pod**: $0/month (vs RDS ~$15-30/month)
- **EKS Cluster**: ~$73/month (control plane)
- **EC2 Nodes**: ~$60/month (2x t3.medium instances)
- **Load Balancer**: ~$18/month (ALB)
- **Total**: ~$151/month (saved ~$15-30/month with pod database)

### **🔗 External Access**
- **Frontend URL**: Live and accessible worldwide
- **Backend API**: Live and accessible worldwide
- **Health Monitoring**: Real-time status checks
- **Auto-scaling**: Responds to traffic automatically

## 📝 Notes

- The application uses PostgreSQL pod for data persistence (no RDS)
- Health checks are implemented for container orchestration
- CORS is enabled for cross-origin requests
- All API responses include proper error handling
- Database schema is automatically created on startup
- Infrastructure is fully managed with Terraform (no RDS resources)
- Security is enforced at multiple levels (PSA, RBAC, NetworkPolicies)
- External access is provided via AWS Load Balancers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎬 Video Presentation

A comprehensive presentation script is available in `PRESENTATION_SCRIPT.md` that includes:
- **19 slides** covering all project aspects
- **Live demo commands** for infrastructure and application deployment
- **Technical deep-dives** into architecture and security
- **Video recording tips** and best practices
- **15-20 minute duration** perfect for technical interviews

### **Key Presentation Highlights:**
- ✅ **Live Application Demo** with external URLs
- ✅ **Infrastructure as Code** with Terraform
- ✅ **Kubernetes Deployment** with security best practices
- ✅ **CI/CD Pipeline** demonstration
- ✅ **Cost Optimization** showcase
- ✅ **Security Compliance** walkthrough

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the documentation
- Use the presentation script for demos

---

**Built with ❤️ using modern DevOps practices**