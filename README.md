# Terraform GCP Multi-Environment Architecture (Dev / Test / Prod)

## Overview

This repository demonstrates a modular, sandbox-compliant Terraform implementation of fully isolated Dev, Test, and Prod environments on Google Cloud Platform. Each environment is provisioned using reusable Terraform modules with isolated remote state files stored in Google Cloud Storage.

Patterns demonstrated: modular Terraform design, remote backend state separation, environment isolation without workspaces, CIDR segmentation strategy, provider version alignment, and real-world debugging with issue resolution.

---

## Architecture Summary

Each environment provisions a custom VPC, a regional subnet, an internal firewall rule, a Compute Engine VM (e2-medium), and isolated remote Terraform state in GCS. All three environments are completely isolated from each other.

---

## CIDR Allocation Strategy

| Environment | Subnet CIDR |
|-------------|-------------|
| Dev | 10.10.0.0/24 |
| Test | 10.20.0.0/24 |
| Prod | 10.30.0.0/24 |

This segmentation ensures clean IP isolation between environments and mirrors real enterprise network planning practices.

---

## Naming Convention

All resources follow the pattern `<project>-<environment>-<region>-<resource>`. Example:

```
playground-s-11-3d8045b7-prod-us-central1-vm
```

This ensures predictable, auditable, and enterprise-compliant resource naming across all environments.

---

## Repository Structure

```
terraform-gcp-sandbox-envs/
    modules/
        network/
            main.tf
            variables.tf
            outputs.tf
        compute/
            main.tf
            variables.tf
            outputs.tf
    envs/
        dev/
            backend.tf
            main.tf
            variables.tf
            terraform.tfvars
        test/
            backend.tf
            main.tf
            variables.tf
            terraform.tfvars
        prod/
            backend.tf
            main.tf
            variables.tf
            terraform.tfvars
    screenshots/
    .gitignore
    README.md
```

---

## Remote State Architecture

All environments share a single GCS bucket but use isolated state prefixes:

```
terraform/state/dev
terraform/state/test
terraform/state/prod
```

This provides clean environment separation, independent state management, safe parallel deployments, and prevents cross-environment state corruption.

---

## Deployment Instructions

### Prerequisites

- Google Cloud project with Compute Engine and Cloud Storage APIs enabled
- Terraform >= 1.5
- GCS bucket created for backend state
- Authenticated gcloud CLI

### Deploy Dev

```bash
cd envs/dev
terraform init
terraform plan
terraform apply
```

### Deploy Test

```bash
cd envs/test
terraform init
terraform plan
terraform apply
```

### Deploy Prod

```bash
cd envs/prod
terraform init
terraform plan
terraform apply
```

Each environment is deployed independently.

---

## Verification

After deployment the following resources should exist:

**VPC Networks**
- `playground-s-11-3d8045b7-dev-us-central1-vpc`
- `playground-s-11-3d8045b7-test-us-central1-vpc`
- `playground-s-11-3d8045b7-prod-us-central1-vpc`

**Subnets:** 10.10.0.0/24, 10.20.0.0/24, 10.30.0.0/24

**VM Instances**
- `playground-s-11-3d8045b7-dev-us-central1-vm`
- `playground-s-11-3d8045b7-test-us-central1-vm`
- `playground-s-11-3d8045b7-prod-us-central1-vm`

Each VM is labeled with environment, application, owner, managed_by, and sandbox.

---

## Issues Encountered and Fixes

### 1. Unsupported Labels on Network Resources

Provider v7.x does not support `labels` on `google_compute_network`, `google_compute_subnetwork`, or `google_compute_firewall`. Fix: removed labels from network resources and retained them only on compute instances.

### 2. Module Variable Mismatch

`An argument named "project_id" is not expected here` - caused by missing or incorrectly defined variables in module `variables.tf`. Fix: explicitly defined all required variables in module variable files.

### 3. Missing Compute Module Invocation

Terraform plan showed only 3 resources instead of 4 because the `module "compute"` block was missing from the environment `main.tf`. Fix: re-added the compute module block.

### 4. Incorrect Directory Structure

A nested `envs/prod/dev/` folder was created accidentally. Fix: moved files up one level and removed the nested directory.

### 5. Backend Reconfiguration Required

Changing a backend prefix requires reinitialization. Fix:

```bash
terraform init -reconfigure
```

### 6. Windows Line Ending Warnings

Git displayed LF to CRLF conversion warnings on Windows. Fix:

```bash
git config --global core.autocrlf true
```

---

## Estimated Cost

Per environment: e2-medium VM (2 vCPU, 4GB RAM) approximately $25-30/month, 20GB persistent disk approximately $2-3/month, VPC/subnet/firewall at no additional cost. Total for all three environments running 24/7 is approximately $85-100/month. Lab and sandbox usage will be significantly lower.

---

## Cleanup

```bash
cd envs/dev && terraform destroy
cd ../test && terraform destroy
cd ../prod && terraform destroy
```

Remote state files remain in GCS unless manually deleted.

---

## Future Enhancements

- Cloud SQL per environment
- GKE cluster in Prod
- Terraform workspaces model
- GitHub Actions CI/CD pipeline
- Private networking enhancements

---

## Author

**Gregory B. Horne**
Cloud Solutions Architect

[GitHub: gbhorne](https://github.com/gbhorne) | [LinkedIn](https://linkedin.com/in/gbhorne)
