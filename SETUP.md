# Code Quest - DevOps Project Setup Guide

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ (for local development)
- Git

### Running the Application

#### Option 1: Docker Compose (Recommended)
```bash
# Clone the repository
git clone <your-repo-url>
cd Code-Quest

# Start all services (PostgreSQL + Backend + Frontend)
docker-compose up --build

# Access the application
# Frontend: http://localhost:8080
# Backend API: http://localhost:3000
# PostgreSQL: localhost:5432
```

#### Option 2: Local Development
```bash
# Install dependencies
npm run install-all

# Start PostgreSQL (requires local PostgreSQL installation)
# Create database: todoapp
# Username: todoapp, Password: todoapp123

# Start the application
npm run dev
```

## 📋 Current Features

### ✅ Completed
- **3-Tier Architecture**: Frontend (Nginx), Backend (Express.js), Database (PostgreSQL)
- **Docker Compose**: Local development environment with health checks
- **Database Integration**: PostgreSQL with proper connection handling
- **REST API**: POST /addTask, GET /listTasks, DELETE /deleteTask
- **Health Endpoint**: GET /health for monitoring

### 🔄 In Progress
- Kubernetes manifests and Helm charts
- AWS EKS infrastructure with Terraform
- CI/CD pipelines with security scanning
- Monitoring and observability stack
- Security policies and RBAC

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   PostgreSQL    │
│   (Nginx)       │◄──►│   (Express.js)  │◄──►│   Database      │
│   Port: 8080    │    │   Port: 3000    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Development Commands

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

# Rebuild specific service
docker-compose up --build backend
```

## 🔧 Configuration

### Environment Variables
The backend uses the following environment variables:
- `DB_HOST`: Database host (default: localhost)
- `DB_PORT`: Database port (default: 5432)
- `DB_NAME`: Database name (default: todoapp)
- `DB_USER`: Database user (default: todoapp)
- `DB_PASSWORD`: Database password (default: todoapp123)
- `NODE_ENV`: Environment (default: production)

### Database Schema
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🚧 Next Steps

To complete the DevOps requirements, the following components need to be implemented:

1. **Kubernetes Deployment**
   - Deployment manifests
   - Services and Ingress
   - ConfigMaps and Secrets
   - HPA (Horizontal Pod Autoscaler)

2. **Helm Charts**
   - Application chart
   - Database chart
   - Values files for different environments

3. **AWS Infrastructure**
   - EKS cluster setup
   - VPC and networking
   - RDS for PostgreSQL
   - Load balancers and security groups

4. **CI/CD Pipelines**
   - GitHub Actions workflows
   - Security scanning (Trivy, Snyk)
   - Image signing and scanning
   - Automated testing

5. **Monitoring & Observability**
   - Prometheus and Grafana
   - ELK/OpenSearch stack
   - Jaeger for tracing
   - Alerting rules

6. **Security**
   - Pod Security Standards
   - Network Policies
   - RBAC configuration
   - Secrets management

7. **Stress Testing**
   - Locust scripts
   - HPA validation
   - Performance testing

## 📊 API Endpoints

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/health` | Health check | - | `{status: "OK", timestamp: "..."}` |
| GET | `/listTasks` | List all tasks | - | `{tasks: [...]}` |
| POST | `/addTask` | Add new task | `{name: "task name"}` | `{message: "...", task: {...}, tasks: [...]}` |
| DELETE | `/deleteTask` | Delete task | `{id: 1}` | `{message: "...", tasks: [...]}` |

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
```

## 📝 Notes

- The application uses in-memory storage for development but PostgreSQL for production
- Health checks are implemented for container orchestration
- CORS is enabled for cross-origin requests
- All API responses include proper error handling
- Database schema is automatically created on startup
