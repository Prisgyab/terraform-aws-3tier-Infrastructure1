# Provisioning a Secure AWS Environment with Terraform

> A portfolio-ready Infrastructure as Code project — built entirely with Terraform, no console clicking.

---

## What This Is

This project provisions a complete, secure 3-tier AWS environment from scratch using Terraform. Every resource — the network, compute instance, and database — is defined in `.tf` files, version-controlled in GitHub, and deployable with a single command.

No manual console work. No drift. No guessing.

This is exactly how infrastructure is managed at real tech companies. A new engineer clones the repo, runs `terraform apply`, and the entire environment comes up automatically.

---

## Why I Built This

Cloud engineers who only know how to click around the AWS console aren't competitive anymore. Employers want infrastructure defined as code — versioned, repeatable, and reviewable. Terraform is the industry-standard tool for that, and it's cloud-agnostic, so the same skills apply to AWS, GCP, and Azure.

I built this project to prove I can do it the right way.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.0.0/16)                    │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────────┐    │
│  │   Public Subnet      │  │   Private Subnet          │    │
│  │   (10.0.1.0/24)      │  │   (10.0.2.0/24)           │    │
│  │                      │  │                           │    │
│  │  ┌──────────────┐    │  │  ┌───────────────────┐   │    │
│  │  │   EC2        │────┼──┼─▶│   RDS MySQL       │   │    │
│  │  │  t3.micro    │    │  │  │  (private subnet) │   │    │
│  │  └──────────────┘    │  │  └───────────────────┘   │    │
│  │         │            │  │                           │    │
│  └─────────┼────────────┘  └──────────────────────────┘    │
│            │                                                │
│  ┌─────────▼────────────┐                                  │
│  │  Internet Gateway     │                                  │
│  └─────────┬────────────┘                                  │
└────────────┼────────────────────────────────────────────────┘
             │
          Internet
```

The environment is split into three tiers:

- **Network layer** — VPC, public/private subnets, Internet Gateway, route tables
- **Compute layer** — EC2 instance (t3.micro) in the public subnet
- **Database layer** — RDS MySQL in the private subnet, unreachable from the internet

---

## What Gets Provisioned

### Remote State Backend (S3)
- S3 bucket stores the Terraform state file remotely
- Any team member can run Terraform and pick up exactly where another left off
- State locking prevents concurrent `terraform apply` conflicts

### Network Layer (VPC)
- VPC with a custom CIDR block (`10.0.0.0/16`)
- Public subnet (`10.0.1.0/24`) for EC2
- Private subnet (`10.0.2.0/24`) for RDS
- Internet Gateway attached to the VPC
- Route table directing public traffic through the gateway

### Compute Layer (EC2)
- EC2 instance (`t3.micro`) in the public subnet
- Security group: SSH (port 22) from your IP, HTTP (port 80) from anywhere
- IAM instance role attached
- Key pair for SSH access

### Database Layer (RDS)
- RDS MySQL instance in the private subnet
- DB subnet group spanning both subnets
- Security group: MySQL (port 3306) from the EC2 security group only
- Credentials managed via Terraform variables — never hardcoded

### Security Groups
| Resource | Inbound Rule | Source |
|----------|-------------|--------|
| EC2 | SSH (22) | Your IP only |
| EC2 | HTTP (80) | Anywhere |
| RDS | MySQL (3306) | EC2 security group only |

No public access to the database. Ever.

---

## Tools & Services Used

| Tool / Service | Purpose |
|----------------|---------|
| Terraform | Infrastructure as Code |
| Amazon VPC | Networking — subnets, route tables, Internet Gateway |
| Amazon EC2 | Compute instance (public subnet) |
| Amazon RDS | MySQL database (private subnet) |
| Amazon S3 | Remote Terraform state backend |
| AWS IAM | EC2 instance role, least-privilege permissions |
| Security Groups | Network access control between tiers |

---

## How It Works — End to End

```bash
# 1. Initialize — downloads the AWS provider, connects to S3 backend
terraform init

# 2. Plan — shows exactly what will be created, no changes yet
terraform plan

# 3. Apply — provisions everything in the correct dependency order
terraform apply

# 4. Destroy — tears down every resource cleanly when done
terraform destroy
```

Terraform handles the dependency order automatically:
1. VPC, subnets, and Internet Gateway (network layer)
2. Security groups
3. EC2 instance (public subnet)
4. RDS instance (private subnet)

---

## Getting Started

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/install) installed (`terraform --version` to confirm)
- AWS CLI configured with valid credentials (`aws configure`)
- An S3 bucket created for the remote state backend

### Secrets & Credentials

No real credentials or key material are committed to this repo — `terraform.tfvars`, `terraform-ec2-key`, and `terraform-ec2-key.pub` are gitignored.

Before running Terraform:

```bash
# 1. Generate your own EC2 key pair (never commit the private key)
ssh-keygen -t rsa -b 4096 -f terraform-ec2-key -N ""

# 2. Copy the example vars file and fill in real values
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your own db_username / db_password
```

### Setup

```bash
# Clone the repo
git clone https://github.com/[your-username]/[repo-name].git
cd [repo-name]

# Initialize Terraform
terraform init

# Preview the infrastructure plan
terraform plan

# Provision everything
terraform apply
```

After apply completes, SSH into the EC2 instance and verify it can reach RDS on port 3306.

```bash
ssh -i your-key.pem ec2-user@<ec2-public-ip>
mysql -h <rds-endpoint> -u admin -p
```

### Tear Down

```bash
terraform destroy
```

All resources are removed. No forgotten instances racking up charges.

---

## Project Structure

```
.
├── provider.tf              # AWS provider + Terraform version constraints
├── vpc.tf                   # VPC, subnets, Internet Gateway, route tables
├── security_groups.tf       # Security groups for EC2 and RDS
├── ec2.tf                   # EC2 instance + key pair
├── rds.tf                   # RDS MySQL instance + subnet group
├── variables.tf             # Input variables (no hardcoded secrets)
├── outputs.tf                # EC2 IP, RDS endpoint, etc.
├── backend.tf                # S3 remote state configuration
└── terraform.tfvars.example  # Copy to terraform.tfvars and fill in real values (gitignored)
```

---

## Estimated Cost

| Resource | Free Tier | Estimated Cost |
|----------|-----------|----------------|
| EC2 t3.micro | 750 hrs/month | ~$0.00 |
| RDS db.t3.micro | 750 hrs/month | ~$0.00 |
| S3 state storage | Negligible | ~$0.00 |

Total estimated cost: **$0.00 – $0.50** for the duration of this project on a new AWS account. Always run `terraform destroy` when finished.

---

## Student Checklist

- [x] Terraform installed and `terraform --version` confirmed
- [x] AWS CLI configured with correct credentials
- [x] S3 bucket created for remote state backend
- [x] `terraform init` completed successfully
- [x] VPC, subnets, and Internet Gateway provisioned
- [x] EC2 instance running in public subnet
- [x] RDS instance running in private subnet
- [x] Security groups correctly restricting access between tiers
- [x] SSH into EC2 successful
- [x] EC2 to RDS connectivity verified on port 3306
- [x] `terraform plan` output reviewed before every apply
- [x] `terraform destroy` completed — all resources removed
- [x] Project documented on GitHub

---

## The Problem This Solves

Teams that manage infrastructure manually run into the same problems over and over:

- No consistency — every environment is slightly different because humans make different choices
- No audit trail — no record of who created what, when, or why
- Slow onboarding — new engineers follow long, error-prone manual guides
- Drift — someone changes a security group in the console and nobody knows until something breaks
- No rollback — reverting a bad manual change is painful

This project solves all of that. The infrastructure is fully defined in code, versioned in Git, and reproducible by anyone on the team.

---

## What I Learned

- How to structure a real Terraform project with remote state
- How to design a 3-tier AWS architecture with proper network isolation
- How security groups work as a firewall between tiers
- Why IaC matters — and how to actually do it, not just talk about it

---

*Built as part of a cloud engineering curriculum. Feedback welcome.*
