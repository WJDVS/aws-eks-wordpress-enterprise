# AWS EKS Enterprise WordPress Infrastructure

An enterprise-grade, highly available WordPress architecture deployed on **Amazon EKS (Elastic Kubernetes Service)** using **Terraform** for Infrastructure as Code (IaC), **Kubernetes/Helm** for orchestration, and automated CI/CD pipelines.

---

## 🏗️ Architecture Overview

An enterprise-grade, highly available WordPress architecture deployed on **Amazon EKS (Elastic Kubernetes Service)** using **Terraform** for Infrastructure as Code (IaC), **Kubernetes/Helm** for orchestration, and automated CI/CD pipelines.

![AWS EKS Enterprise WordPress Architecture](docs/screenshots/architecture-diagram.png)

- **Cloud Provider:** AWS (`us-east-1`)
- **Infrastructure as Code:** Terraform (Modular setup: VPC, EKS, RDS, EFS)
- **Container Orchestration:** Kubernetes (EKS Managed Node Groups, HPA)
- **Database:** Amazon RDS for MySQL (Multi-AZ Primary & Standby)
- **Storage:** Amazon EFS for persistent shared WordPress content (`wp-content/uploads`)

---

## 📑 Phase 1: Repository Setup, Folder Structure & Version Control

### 🎯 Phase Objectives
- Establish the central Git repository on GitHub (`aws-eks-wordpress-enterprise`) as the project's single source of truth.
- Initialize a local workspace in Visual Studio Code with a modular, scalable directory tree.
- Define initial placeholder configuration files for Terraform, Kubernetes manifests, and automated GitHub Actions workflows.
- Set up project documentation and portfolio screenshot tracking.

---

## 📂 Project Directory Structure

```text
aws-eks-wordpress-enterprise/
├── .github/workflows/          # CI/CD GitHub Actions pipelines
├── docs/screenshots/           # Visual portfolio documentation
├── terraform/                  # Terraform Infrastructure as Code
│   ├── main.tf                 # Core provider configuration
│   ├── variables.tf            # Input configuration variables
│   ├── outputs.tf              # Connection endpoints and outputs
│   ├── vpc.tf                  # Networking, subnets, and routing
│   ├── eks.tf                  # EKS cluster and compute nodes
│   ├── rds.tf                  # Multi-AZ MySQL database
│   └── efs.tf                  # Elastic File System storage
└── kubernetes/                 # Kubernetes deployment manifests
    ├── wordpress-deployment.yaml
    ├── wordpress-service.yaml
    ├── persistent-volume.yaml
    └── hpa.yaml