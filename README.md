# Terraform GCP Multi-Environment Architecture (Dev / Test / Prod)

## Overview

This repository demonstrates a modular, sandbox-compliant Terraform implementation of fully isolated Dev, Test, and Prod environments in Google Cloud Platform (GCP).

Each environment is provisioned using reusable Terraform modules and isolated remote state files stored in Google Cloud Storage (GCS).

This project demonstrates:

- Modular Terraform design
- Remote backend state separation
- Environment isolation without workspaces
- Clean naming conventions
- CIDR segmentation strategy
- Provider version alignment
- Real-world debugging and issue resolution
- Enterprise-ready Infrastructure as Code patterns

---

## Architecture Summary

Each environment provisions:

- 1 Custom VPC (Regional)
- 1 Regional Subnet
- 1 Internal Firewall Rule
- 1 Compute Engine VM (e2-medium)
- Remote Terraform state in GCS

All environments are completely isolated from each other.

---

## CIDR Allocation Strategy

| Environment | Subnet CIDR |
|------------|------------|
| Dev        | 10.10.0.0/24 |
| Test       | 10.20.0.0/24 |
| Prod       | 10.30.0.0/24 |

This segmentation ensures clean IP isolation between environments and mirrors real enterprise network planning practices.

---

## Naming Convention

All resources follow the pattern:

<project>-<environment>-<region>-<resource>


Example:

playground-s-11-3d8045b7-prod-us-central1-vm


This ensures predictable, auditable, and enterprise-compliant resource naming.

---

## Repository Structure

```text
terraform-gcp-sandbox-envs/
│
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── storage/
│
├── envs/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   │
│   ├── test/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   │
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
│
├── screenshots/
├── .gitignore
└── README.md
```


## Remote State Architecture

All environments share a single GCS bucket but use isolated prefixes:

terraform/state/dev
terraform/state/test
terraform/state/prod


Benefits:

- Clean environment separation
- Independent state management
- Safe parallel deployments
- Enterprise-ready backend pattern
- Prevents cross-environment state corruption

---

## Deployment Instructions

### Prerequisites

- Google Cloud Project
- Compute Engine API enabled
- Cloud Storage API enabled
- Terraform >= 1.5
- GCS bucket created for backend state
- Authenticated gcloud CLI

---

### Deploy Dev

cd envs/dev
terraform init
terraform plan
terraform apply


---

### Deploy Test

cd envs/test
terraform init
terraform plan
terraform apply


---

### Deploy Prod

cd envs/prod
terraform init
terraform plan
terraform apply


Each environment is deployed independently.

---

## Verification

After deployment you should see:

### VPC Networks
- playground-s-11-3d8045b7-dev-us-central1-vpc
- playground-s-11-3d8045b7-test-us-central1-vpc
- playground-s-11-3d8045b7-prod-us-central1-vpc

### Subnets
- 10.10.0.0/24
- 10.20.0.0/24
- 10.30.0.0/24

### VM Instances
- playground-s-11-3d8045b7-dev-us-central1-vm
- playground-s-11-3d8045b7-test-us-central1-vm
- playground-s-11-3d8045b7-prod-us-central1-vm

Each VM is labeled with:

- environment
- application
- owner
- managed_by
- sandbox

---

## Issues Faced and Fixes

### 1. Unsupported Labels on Network Resources

Issue:
Provider v7.x does not support `labels` on:
- google_compute_network
- google_compute_subnetwork
- google_compute_firewall

Error:
Unsupported argument: labels


Fix:
Removed labels from network resources.
Retained labels only on compute instances.

---

### 2. Module Variable Mismatch

Issue:
An argument named "project_id" is not expected here


Cause:
Missing or incorrectly defined variables in module `variables.tf`.

Fix:
Explicitly defined all required variables in module variable files.

---

### 3. Missing Compute Module Invocation

Issue:
Terraform plan showed only 3 resources instead of 4.

Cause:
`module "compute"` block was missing in environment `main.tf`.

Fix:
Re-added compute module block correctly.

---

### 4. Incorrect Directory Structure

Issue:
Nested folder created:
envs/prod/dev/


Fix:
Moved files up one level and removed nested directory.

---

### 5. Backend Reconfiguration Required

Issue:
Changing backend prefix required reinitialization.

Fix:
terraform init -reconfigure


---

### 6. Windows Line Ending (CRLF) Warnings

Issue:
Git displayed warnings about LF → CRLF conversion.

Cause:
Windows default line-ending behavior.

Fix:
Configured Git:
git config --global core.autocrlf true


---

## Estimated Cost (Approximate)

Per environment:

- e2-medium VM (2 vCPU, 4GB RAM): ~$25–30/month
- 20GB persistent disk: ~$2–3/month
- VPC / Subnet / Firewall: No additional cost

Total for 3 environments (if running 24/7):

~$85–100/month

Note:
This estimate assumes continuous runtime. Lab or sandbox usage will be significantly lower.

---

## Cleanup Instructions

To destroy an environment:

cd envs/dev
terraform destroy


Repeat for test and prod.

To remove all environments:

cd envs/dev && terraform destroy
cd ../test && terraform destroy
cd ../prod && terraform destroy


Remote state files remain in GCS unless manually deleted.

---

## Enterprise Patterns Demonstrated

- Modular Terraform design
- Remote state isolation
- Multi-environment separation
- Naming governance
- CIDR segmentation
- Provider compatibility management
- Debugging and issue resolution
- Infrastructure repeatability
- Clean Git hygiene
- Production-ready folder structure

---

## Future Enhancements

- Add Cloud SQL per environment
- Add GKE cluster in Prod
- Convert to Terraform workspaces model
- Add GitHub Actions CI/CD
- Add cost-optimization improvements
- Add private networking enhancements

---

## Author

Gregory Horne  
Cloud Infrastructure & Multi-Cloud Architect
