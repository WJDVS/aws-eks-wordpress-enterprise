# AWS EKS Enterprise WordPress Infrastructure

An enterprise-grade, highly available WordPress architecture deployed on **Amazon EKS (Elastic Kubernetes Service)**, using **Terraform** for Infrastructure as Code (IaC), **Kubernetes/Helm** for orchestration, and automated **CI/CD** pipelines.

---

## 🏗️ Architecture Overview

![AWS EKS Enterprise WordPress Architecture](docs/screenshots/architecture-diagram.png)

### 📋 Implementation Status

The diagram shows the **target architecture**. This table tracks what is built today.

| Component | Status |
| :--- | :--- |
| VPC, public/private subnets, NAT, Multi-AZ layout | ✅ Implemented |
| Amazon EKS cluster with managed node group | ✅ Implemented (2–4 nodes; target 3–6) |
| Amazon RDS for MySQL (Multi-AZ) | ✅ Implemented |
| Amazon EFS shared storage | ✅ Implemented |
| Application Load Balancer via AWS Load Balancer Controller + Ingress | ✅ Implemented |
| AWS WAF (managed rule groups) | ✅ Implemented |
| Amazon CloudFront (HTTPS front door) | ✅ Implemented (S3 origin not yet) |
| Kubernetes Secrets and credential rotation | ✅ Implemented |
| Horizontal Pod Autoscaler and 2+ replicas | 🔜 Planned |
| Amazon ElastiCache for Redis | 🔜 Planned |
| Amazon S3 media offload served through CloudFront | 🔜 Planned |
| Terraform Cloud / remote state | 🔜 Planned |
| GitHub Actions CI/CD | 🔜 Planned |

### 🧰 Technology Stack

| Component | Technology |
| :--- | :--- |
| **Cloud Provider** | AWS (`us-east-1`) |
| **Infrastructure as Code** | Terraform (VPC, EKS, RDS, EFS, WAF, CloudFront) |
| **Container Orchestration** | Kubernetes (EKS Managed Node Groups) |
| **Edge / HTTPS** | Amazon CloudFront (default `*.cloudfront.net` certificate) |
| **Web Application Firewall** | AWS WAFv2 (AWS managed rule groups) attached to the ALB |
| **Load Balancing** | Application Load Balancer managed by the AWS Load Balancer Controller |
| **Database** | Amazon RDS for MySQL (Multi-AZ Primary & Standby) |
| **Storage** | Amazon EFS for persistent shared WordPress content (`wp-content/uploads`) |
| **CI/CD** | GitHub Actions (planned) |

---

## 📑 Table of Contents

- [Phase 1: Repository Setup, Folder Structure & Version Control](#-phase-1-repository-setup-folder-structure--version-control)
- [Phase 2: Infrastructure Provisioning (Terraform)](#-phase-2-infrastructure-provisioning-terraform)
- [Phase 3: Kubernetes Orchestration & Storage Configuration](#-phase-3-kubernetes-orchestration--storage-configuration)
- [Phase 4: Ingress, Load Balancing & Security](#-phase-4-ingress-load-balancing--security)
- [Roadmap](#-roadmap)

---

## 📦 Phase 1: Repository Setup, Folder Structure & Version Control

### 🎯 Phase Objectives

- Establish the central Git repository on GitHub (`aws-eks-wordpress-enterprise`) as the project's single source of truth.
- Initialize a local workspace in Visual Studio Code with a modular, scalable directory tree.
- Define initial placeholder configuration files for Terraform, Kubernetes manifests, and automated GitHub Actions workflows.
- Set up project documentation and portfolio screenshot tracking.

### 📂 Project Directory Structure (Current)

```text
aws-eks-wordpress-enterprise/
├── .github/workflows/          # CI/CD GitHub Actions pipelines (planned)
├── docs/screenshots/           # Visual portfolio documentation
├── terraform/                  # Terraform Infrastructure as Code
│   ├── main.tf                 # Core provider configuration
│   ├── variables.tf            # Input configuration variables
│   ├── outputs.tf              # Connection endpoints and outputs
│   ├── vpc.tf                  # Networking, subnets, and routing
│   ├── security.tf             # Security groups and network access rules
│   ├── eks.tf                  # EKS cluster and compute nodes
│   ├── rds.tf                  # Multi-AZ MySQL database
│   ├── efs.tf                  # Elastic File System storage
│   ├── waf.tf                  # WAFv2 Web ACL with managed rule groups
│   ├── cloudfront.tf           # CloudFront distribution (HTTPS front door)
│   └── .terraform.lock.hcl     # Provider version lock file
├── kubernetes/                 # Kubernetes deployment manifests
│   ├── storage-class.yaml      # EFS StorageClass (efs.csi.aws.com)
│   ├── persistent-volume.yaml  # Persistent volume configuration
│   ├── wordpress-pvc.yaml      # ReadWriteMany PersistentVolumeClaim
│   ├── wordpress-deployment.yaml
│   ├── wordpress-service.yaml
│   ├── ingress.yaml            # ALB Ingress (WAF + CloudFront-only access)
│   └── hpa.yaml                # Horizontal Pod Autoscaler (planned)
├── iam_policy.json             # AWS Load Balancer Controller IAM policy
├── trust-policy.json           # IAM trust policy
├── .gitignore
└── README.md
```

### 📸 Portfolio Screenshots (Phase 1)

| Screenshot File Name | Visual Proof / Content Description |
| :--- | :--- |
| `docs/screenshots/phase1-github-repo.png` | GitHub repository home page showing `aws-eks-wordpress-enterprise` and the base `.gitignore`. |
| `docs/screenshots/phase1-vscode-structure.png` | VS Code Explorer tree displaying all created directories (`terraform/`, `kubernetes/`, `docs/screenshots/`) and placeholder `.tf` / `.yaml` files. |

![Phase 1 - GitHub Repository Setup](docs/screenshots/phase1-github-repo.png)
![Phase 1 - VS Code Directory Structure](docs/screenshots/phase1-vscode-structure.png)

> **Note:** Screenshots reflect the initial Phase 1 scaffold; the structure above includes files added in later phases.

---

## 📁 Phase 2: Infrastructure Provisioning (Terraform)

### 🎯 Phase Objectives

- Configure core AWS provider settings and reusable input variables (`main.tf`, `variables.tf`).
- Provision a highly available Multi-AZ Virtual Private Cloud (`vpc.tf`) featuring public and private subnets, internet gateways, and NAT gateways.
- Deploy an enterprise Amazon EKS cluster (`eks.tf`) running version `1.31` with managed EC2 node groups across private subnets.
- Set up a highly available, Multi-AZ Amazon RDS MySQL database (`rds.tf`) for application data persistence.
- Implement an encrypted Amazon EFS file system (`efs.tf`) with mount targets across all private subnets to provide shared storage for WordPress uploads.

### 🛠️ Step-by-Step Provisioning Summary

#### 1. Core Providers & Input Variables (`main.tf`, `variables.tf`)

- Configured the HashiCorp AWS provider (`~> 5.0`) targeting region `us-east-1`.
- Standardized tags applied globally to all AWS resources:
  - `Project = "aws-eks-wordpress-enterprise"`
  - `ManagedBy = "Terraform"`
  - `Environment = "production"`

#### 2. Multi-AZ Networking (`vpc.tf`)

- Provisioned a VPC with CIDR block `10.0.0.0/16` across Availability Zones `us-east-1a` and `us-east-1b`.
- Configured public subnets (`10.0.1.0/24`, `10.0.2.0/24`) and private subnets (`10.0.10.0/24`, `10.0.11.0/24`).
- Added Kubernetes auto-discovery tags (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`) so the load balancer controller can identify subnets automatically.

#### 3. Kubernetes Cluster & Compute (`eks.tf`)

- Deployed the Amazon EKS cluster `aws-eks-wordpress-cluster` on Kubernetes `v1.31`.
- Configured EKS Managed Node Groups with `t3.medium` instances across private subnets, with auto-scaling boundaries of minimum 2, desired 2, and maximum 4 nodes.

#### 4. Relational Database (`rds.tf`)

- Provisioned an Amazon RDS MySQL 8.0 instance (`db.t3.micro`) with Multi-AZ replication for high availability and failover.
- Placed RDS inside private database subnet groups with restricted network access.

#### 5. Persistent Shared Storage (`efs.tf`)

- Created an encrypted Amazon EFS file system (`aws-eks-wordpress-efs`) in general-purpose mode.
- Deployed EFS mount targets across private subnets with a dedicated security group permitting NFS traffic (port `2049`) from the VPC CIDR. *(Narrowed to the EKS worker node security group in Phase 4.)*

### 📸 Portfolio Screenshots (Phase 2)

| Screenshot File Name | Visual Proof / Content Description |
| :--- | :--- |
| `docs/screenshots/phase2-vpc-plan.png` | Terminal output showing successful execution of `terraform plan` for VPC network provisioning. |
| `docs/screenshots/phase2-eks-apply.png` | Successful `terraform apply` log output confirming EKS control plane and node group creation. |
| `docs/screenshots/phase2-rds-apply.png` | Terminal confirmation showing the Multi-AZ RDS MySQL database successfully created. |
| `docs/screenshots/phase2-efs-apply.png` | Terminal confirmation verifying the EFS file system, security group, and mount targets created. |

![Phase 2 - VPC Plan Execution](docs/screenshots/phase2-vpc-plan.png)
![Phase 2 - EKS Cluster Apply](docs/screenshots/phase2-eks-apply.png)
![Phase 2 - Multi-AZ RDS Apply](docs/screenshots/phase2-rds-apply.png)
![Phase 2 - EFS Shared Storage Apply](docs/screenshots/phase2-efs-apply.png)

---

## 🚀 Phase 3: Kubernetes Orchestration & Storage Configuration

> **Note:** AWS resource IDs in this section are masked. Items marked *(Replaced in Phase 4)* describe the initial Phase 3 setup, which Phase 4 later hardened.

### 🎯 Phase Objectives

- Establish cluster credentials and authenticate `kubectl` against the newly provisioned Amazon EKS control plane.
- Implement dynamic persistent volume storage backed by AWS EFS using the `efs.csi.aws.com` provisioner to support multi-pod shared media storage.
- Secure database connectivity by authorizing MySQL port `3306` ingress from the EKS Node Security Group into the RDS Security Group.
- Deploy stateful WordPress container workloads configured to use remote AWS RDS for database operations and AWS EFS for content storage.
- Verify complete application initialization, schema migration, and administrative panel access.

### 🛠️ Step-by-Step Orchestration Summary

#### 1. Cluster Authentication & Storage Class Setup

- Configured the local `kubeconfig` context for the Amazon EKS cluster using `aws eks update-kubeconfig`.
- Deployed the `efs-sc` StorageClass utilizing `efs.csi.aws.com` in Access Point mode (`efs-ap`) pointing to EFS file system `fs-0xxxxxxxxxxxxxxxx`.
- Created `wordpress-efs-pvc` with `ReadWriteMany` (RWX) access mode, enabling simultaneous read and write access across auto-scaled pods.

#### 2. Network Inbound Authorization & Security

- Identified the EKS worker node security group (`sg-0xxxxxxxxxxxxxxxx`).
- Updated the RDS security group (`sg-0yyyyyyyyyyyyyyyy`) with an inbound rule permitting MySQL/Aurora traffic (TCP port `3306`) sourced directly from the EKS worker nodes.

#### 3. WordPress Workload Deployment & Verification

- Configured the RDS database credentials for the WordPress container as environment variables. *(They were initially plain values in the Deployment manifest; Phase 4 moved them into a Kubernetes Secret and rotated the password.)*
- Applied `wordpress-deployment.yaml` and `wordpress-service.yaml`, creating an AWS Classic Load Balancer pointing to port `80` of the WordPress pods. *(Replaced in Phase 4 by an Application Load Balancer created from an Ingress.)*
- Established local tunneling via `kubectl port-forward` to test and complete the WordPress installation wizard.
- Verified database writing and table schema creation on AWS RDS via successful login to `/wp-admin/`.

### 📸 Portfolio Screenshots (Phase 3)

| Screenshot File Name | Visual Proof / Content Description |
| :--- | :--- |
| `docs/screenshots/rds-security-group-inbound-rule.png` | AWS EC2/RDS Security Group configuration displaying the inbound rule for MySQL/Aurora traffic on port `3306` authorized from the EKS Node Security Group (`sg-0xxxxxxxxxxxxxxxx`). |
| `docs/screenshots/wordpress-already-installed.png` | WordPress setup interface (`/wp-admin/install.php`) confirming successful connection to the AWS RDS MySQL instance and existing table schema initialization. |
| `docs/screenshots/wordpress-admin-dashboard.png` | Active WordPress Administrative Dashboard (`/wp-admin/`) demonstrating complete application accessibility and system state integrity. |
| `docs/screenshots/kubectl-cluster-resources.png` | Terminal output displaying `kubectl get pods -o wide`, `kubectl get pvc,pv`, and `kubectl get svc`, verifying running WordPress pods (`1/1 Running`), bound EFS PersistentVolumeClaim (`5Gi`, RWX), and active LoadBalancer. |

![Phase 3 - RDS Security Group Inbound Rule](docs/screenshots/rds-security-group-inbound-rule.png)
![Phase 3 - WordPress Install Page](docs/screenshots/wordpress-already-installed.png)
![Phase 3 - WordPress Admin Dashboard](docs/screenshots/wordpress-admin-dashboard.png)
![Phase 3 - kubectl Cluster Resources](docs/screenshots/kubectl-cluster-resources.png)

---

## 🔐 Phase 4: Ingress, Load Balancing & Security

### 🎯 Phase Objectives

- Replace the Phase 3 Classic Load Balancer with an **Application Load Balancer** created from a Kubernetes **Ingress** by the AWS Load Balancer Controller.
- Remove hardcoded database credentials from the repository using a **Kubernetes Secret** and a **sensitive Terraform variable**, and rotate the exposed password.
- Protect the application with **AWS WAFv2** managed rule groups and verify that attack-style requests are blocked.
- Serve the site over **HTTPS** with **Amazon CloudFront** (no custom domain), and restrict the ALB so only CloudFront can reach it.
- Apply least-privilege network rules to the shared storage.

### 🏗️ Traffic Flow

```text
Browser ──HTTPS──▶ CloudFront ──HTTP──▶ ALB (WAF attached) ──▶ WordPress pod ──▶ RDS MySQL / EFS
```

### 🛠️ Step-by-Step Summary

#### 1. Ingress and Application Load Balancer

- Installed the **AWS Load Balancer Controller** (Helm chart `3.6.0`) with an IAM role bound to its Kubernetes service account (IRSA), so it receives temporary AWS credentials without stored keys.
- Created `wordpress-ingress` (`ingressClassName: alb`, `scheme: internet-facing`, `target-type: ip`) so the ALB sends traffic directly to WordPress pod IPs in the private subnets.
- Health checks use path `/` and accept `200`, `301`, and `302`.
- Changed the `wordpress` Service from `LoadBalancer` to `ClusterIP`, which removed the Phase 3 Classic Load Balancer and its second public entry point.

#### 2. Secrets Management

- Moved the database user and password out of `wordpress-deployment.yaml` into the Kubernetes Secret `wordpress-db-secret`, referenced with `secretKeyRef`.
- Replaced the hardcoded password in `rds.tf` with a **sensitive** Terraform variable (`db_password`) supplied through `TF_VAR_db_password`.
- **Rotated** the RDS master password, so credentials that existed in earlier commits no longer work.
- Verified the Git history contains no state files, key files, or AWS access keys before publishing.
- Disabled WordPress debug mode so PHP errors are not shown to visitors.

#### 3. WordPress Address Handling

- Set `WP_HOME` and `WP_SITEURL` in `WORDPRESS_CONFIG_EXTRA` from the request host and the forwarded protocol (`CloudFront-Forwarded-Proto` and `X-Forwarded-Proto`). This fixed redirects to the port-forward address (`:8080`) left over from the install, and makes WordPress treat HTTPS visitors as secure.

#### 4. Web Application Firewall

- Created a regional WAFv2 Web ACL, `aws-eks-wordpress-waf`, in `waf.tf` with three AWS managed rule groups: **Common Rule Set**, **SQL Injection Rule Set**, and **WordPress Rule Set**.
- Attached it to the ALB with the Ingress annotation `alb.ingress.kubernetes.io/wafv2-acl-arn`.
- Verified protection with harmless attack-style requests (script injection, path traversal, SQL injection pattern). Each returned `403 Forbidden`, while normal requests returned `200`.

#### 5. Network Hardening

- Audited the VPC's security groups: only the ALB's group accepted traffic from `0.0.0.0/0`.
- Narrowed the EFS security group from "NFS (2049) from the whole VPC CIDR" to "NFS from the EKS worker node security group", then deleted the WordPress pod to prove a brand-new pod can still mount the storage.

#### 6. HTTPS with CloudFront

- Created a CloudFront distribution in `cloudfront.tf`: default CloudFront certificate, `redirect-to-https` for viewers, the managed **CachingDisabled** cache policy, and the managed **AllViewerAndCloudFrontHeaders** origin request policy so cookies, headers, and logins work.
- Restricted the ALB to CloudFront using the AWS-managed CloudFront origin-facing **prefix list** (Ingress annotation `security-group-prefix-lists`). A direct request to the ALB now times out, so all traffic passes through CloudFront and then WAF.

### 📸 Portfolio Screenshots (Phase 4)

| Screenshot File Name | Visual Proof / Content Description |
| :--- | :--- |
| `docs/screenshots/phase4-aws-load-balancer.png` | Application Load Balancer created by the AWS Load Balancer Controller from the Ingress. |
| `docs/screenshots/phase4-wordpress-via-alb.png` | WordPress served through the ALB before CloudFront was added. |
| `docs/screenshots/phase4-wordpress-debug-off.png` | WordPress after debug display was disabled. |
| `docs/screenshots/phase4-waf-test-403.png` | Terminal showing `403` responses to script injection, path traversal, and SQL injection patterns. |
| `docs/screenshots/phase4-waf-blocked-requests.png` | WAF console showing blocked requests and the rule groups that matched. |
| `docs/screenshots/phase4-efs-mount.png` | `df -h` inside a freshly started pod showing the EFS mount at `/var/www/html`. |
| `docs/screenshots/phase4-cloudfront-https.png` | WordPress served over HTTPS (padlock) from the CloudFront address. |
| `docs/screenshots/phase4-wp-admin-https.png` | WordPress admin dashboard loaded over HTTPS through CloudFront. |
| `docs/screenshots/phase4-alb-locked-to-cloudfront.png` | ALB security group allowing only the CloudFront prefix list, a direct ALB request timing out, and CloudFront returning `200`. |

![Phase 4 - ALB](docs/screenshots/phase4-aws-load-balancer.png)
![Phase 4 - WordPress via ALB](docs/screenshots/phase4-wordpress-via-alb.png)
![Phase 4 - Debug Off](docs/screenshots/phase4-wordpress-debug-off.png)
![Phase 4 - WAF Test 403](docs/screenshots/phase4-waf-test-403.png)
![Phase 4 - WAF Blocked Requests](docs/screenshots/phase4-waf-blocked-requests.png)
![Phase 4 - EFS Mount](docs/screenshots/phase4-efs-mount.png)
![Phase 4 - CloudFront HTTPS](docs/screenshots/phase4-cloudfront-https.png)
![Phase 4 - WordPress Admin over HTTPS](docs/screenshots/phase4-wp-admin-https.png)
![Phase 4 - ALB Locked to CloudFront](docs/screenshots/phase4-alb-locked-to-cloudfront.png)

### ⚠️ Known Limitations and Next Improvements

- **CloudFront-to-ALB traffic is plain HTTP.** There is no custom domain, so there is no certificate for the ALB. A domain plus an ACM certificate would encrypt that leg.
- **Minimum TLS version is fixed at TLS 1.0** because the default CloudFront certificate is used. A custom domain and certificate would allow requiring TLS 1.2 or newer.
- **Single WordPress replica.** A Horizontal Pod Autoscaler and a second replica would remove the brief outage during pod restarts.
- **WAF request logging is off.** Metrics and sampled requests are enabled. Full logging to CloudWatch or S3 would add cost.
- **Secrets are Kubernetes Secrets**, which are base64-encoded. AWS Secrets Manager with automatic rotation is the next step.
- **Terraform state is local.** Remote state (Terraform Cloud or an S3 backend) is required before CI/CD.
- **The cluster runs Kubernetes 1.31 in EKS extended support**, which carries a higher control plane charge and ends with an automatic control plane upgrade. Moving to a version in standard support, either by upgrading one minor version at a time or by rebuilding, avoids the premium.
- **Cost awareness:** the EKS control plane, worker nodes, NAT gateway, ALB, Multi-AZ RDS, and WAF all accrue hourly charges while the environment runs.
- **Teardown order:** delete the Ingress first (so the controller removes the ALB and detaches its security groups), then run `terraform destroy` for the remaining infrastructure.

---

## 🗺️ Roadmap

| Phase | Focus | Planned Work |
| :--- | :--- | :--- |
| **Phase 5** | Scalability | metrics-server, Horizontal Pod Autoscaler, 2+ WordPress replicas spread across both Availability Zones, node group sized 3–6 |
| **Phase 6** | Performance | Amazon ElastiCache for Redis (object cache), Amazon S3 media offload served through CloudFront |
| **Phase 7** | Automation | Remote Terraform state (Terraform Cloud), GitHub Actions CI/CD |
| **Final** | Documentation | Portfolio documentation and final end-to-end verification |
