🎯 Your Mission: Build a Secure, Observable, Scalable Cloud Environment
Business Context

4Sale is continuously scaling to support millions of users. We need a robust, secure, and observable DevOps setup that balances performance with cost efficiency.

🛠️ Your Tasks

1. Application (Core)

Build a simple 3-tier application consisting of:

Frontend (very simple app served via NGINX inside the cluster -out of the evaluation, just for testing-).

Backend (simple API service):

Choose any simple domain (e.g., Tasks, Notes, Products, Bookmarks). Create endpoints like this:

POST /addTask, DELETE /deleteTask, GET /listTasks

Postgres DB deployed via Helm/Kustomize.

Provide a Docker Compose file for local testing before Kubernetes deployment.

Apply HPA for scaling (document your chosen scaling criteria).

Apply Pod Security Admission (PSA) standards to ensure non-root execution.

Create a Helm chart that deploys the app and DB using templates (bonus points).

Restrict database access using NetworkPolicies (only app namespace can reach it)

⚠️ Note: You may use any open-source three-tier application, or leverage ChatGPT or other AI tools to generate the application.

2. Infrastructure (AWS)

Supply Terraform/Terragrunt (or other IaC tool) to provision:

Networking (VPC, subnets, SGs, etc.)

EKS cluster with core add-ons for storage and networking

Support two accounts (dev & prod) operating in different regions.

We will apply your Terraform plan and evaluate it, so make sure it works.

Include a README with clear steps, notes, and scripts to automate as much as possible.

⚠️ If you don’t have enough AWS credits, you can use MicroK8s, Minikube, K3s, or another local Kubernetes option. Be sure to document the trade-offs (e.g., lack of LoadBalancer support, storage differences). Keep all AWS-related files intact so we can still validate them

3. Stress Testing

Write a Locust script to test scalability & HPA.

Script should be configurable using environment variables.

This script will be used in evaluation to validate autoscaling

4. CI/CD Pipelines
Use GitHub Actions/CircleCI to build a complete DevSecOps pipeline.

Create two pipelines:

App deployment pipeline

Infrastructure pipeline

You should decide the tools and security measures yourself.

We expect to see a complete DevSecOps approach (e.g., image signing, scanning with Trivy/Snyk/Grype, secret management, RBAC, etc.).

Justify your tool choices with simple comparisons.

5. Security
Demonstrate how you enforce (Add your answers to README file):

Access control

DDoS protection & WAF

Data encryption at rest & in transit

Secrets management

Role-based access control (RBAC)

Add tests/checks to validate these security measures

5. Monitoring & Alerts (Advanced)

Add monitoring for logs, uptime, latency, resources, and disk usage for either app or DB or both.

Dashboard for database metrics

Deploy OpenTelemetry and Jaeger on the cluster and ensure application traces appear (bonus points).

Create alerts for:

High CPU (>80% for 5 mins)

Pod crash / restart loops

Postgres down/unavailable

Configure alert delivery via email or webhook.

Describe how you will (Bouns):

Detect anomalies & vulnerabilities

Ensure compliance with regional data regulations

Track costs and apply FinOps principles

🧰 Tech Stack
Cloud: AWS (EKS, RDS, S3, CloudFront)

IaC: Terraform, Helm, or Kustomize

CI/CD: GitHub Actions / CircleCI

Containers: Docker, Kubernetes

Monitoring: Prometheus, Grafana, ELK/OpenSearch

Security: IAM, RBAC, NetworkPolicies, WAF

📝 What You Should Submit
GitHub repo including:

Source code for app

Docker Compose setup

Kubernetes manifests / Helm charts

Infrastructure as Code (Terraform/Terragrunt)

GitHub Actions pipeline configuration

Locust stress test script

README with setup, deployment, and evaluation notes


Short video walkthrough (≤ 15 mins) showing:

Files structure

Terraform architecture

Pipeline design

📊 Evaluation Criteria
Infrastructure as Code (AWS & IaC Design) – 25%

CI/CD Automation & DevSecOps Integration – 25%

Kubernetes Deployment & Scaling (HPA, Helm, policies) – 20%

Monitoring, Logging & Observability – 15%

Security & Compliance Practices – 10%

Documentation & Presentation – 5%