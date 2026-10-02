# AWS Infrastructure CI Pipeline with Terraform

## Project Overview

This project uses Terraform to provision and manage AWS infrastructure and GitHub Actions to automatically validate and plan infrastructure changes.

The project demonstrates Infrastructure as Code (IaC), AWS networking, secure GitHub-to-AWS authentication, remote Terraform state, monitoring, and a Pull Request-based CI workflow.

## Architecture

```text
GitHub
   |
Pull Request
   |
GitHub Actions
   |
OIDC
   |
AWS IAM Role
   |
Terraform
   |
   +---- S3 Remote State
   |
   +---- AWS Infrastructure
            |
            VPC
           /   \
          /     \
 Public Subnet   Private Subnet
      |
     EC2
      |
    Nginx
      |
 CloudWatch Alarm
```

## AWS Infrastructure

Terraform manages the following AWS resources:

- VPC
- Public subnet
- Private subnet
- Internet Gateway
- Public and private route tables
- Public Internet route
- Route table associations
- Security Group
- EC2 web server
- Nginx web server
- CloudWatch high-CPU alarm

The public EC2 instance hosts the Nginx web server.

The private subnet is included as part of the network design but is not directly exposed to the Internet.

## Terraform

Terraform is used to define and manage the AWS infrastructure as code.

The project uses commands including:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform state list
```

Terraform configuration is split into multiple files and includes a reusable network module.

## Remote Terraform State

Terraform state is stored remotely in a private Amazon S3 bucket instead of relying only on a local `terraform.tfstate` file.

The S3 backend uses:

- Private bucket access
- Bucket versioning
- Encryption
- S3 state locking

Remote state allows both my local Terraform environment and GitHub Actions to work with the same infrastructure state.

## GitHub Actions CI

A GitHub Actions workflow runs when a Pull Request targets the `master` branch.

The workflow:

1. Checks out the repository
2. Installs Terraform
3. Checks Terraform formatting
4. Authenticates to AWS
5. Initializes Terraform
6. Validates the Terraform configuration
7. Runs `terraform plan`

This allows infrastructure changes to be reviewed before they are applied to AWS.

## AWS Authentication with OIDC

GitHub Actions authenticates to AWS using OpenID Connect (OIDC).

```text
GitHub Actions
      |
      | OIDC token
      v
AWS IAM Role
      |
      | Temporary credentials
      v
AWS
```

This avoids storing permanent AWS access keys in GitHub.

The IAM role uses a trust policy to control who can assume the role and a permissions policy to control which AWS actions the workflow can perform.

The permissions follow the principle of least privilege.

## CI/CD Workflow

```text
Feature Branch
      |
Terraform Change
      |
Local terraform plan
      |
Commit + Push
      |
Pull Request
      |
GitHub Actions
      |
terraform plan
      |
Review
      |
Merge to master
      |
Manual terraform apply
      |
AWS Updated
```

Currently, CI checks and Terraform planning are automated.

`terraform apply` remains manual so infrastructure changes are reviewed before AWS resources are modified.

## Monitoring

Amazon CloudWatch monitors the EC2 web server.

A high-CPU alarm monitors the EC2 `CPUUtilization` metric and enters the ALARM state when the configured threshold is exceeded.

## Security Practices

This project uses several security practices:

- No permanent AWS access keys stored in GitHub
- OIDC authentication with temporary AWS credentials
- IAM least-privilege permissions
- Private S3 Terraform state
- S3 state encryption
- Terraform state locking
- Security Group rules controlling network access
- Private subnet for resources that should not be directly Internet-facing

## Skills Practiced

This project provided hands-on practice with:

- AWS
- Terraform
- Infrastructure as Code
- VPC networking
- Public and private subnets
- Internet Gateways
- Route tables
- Security Groups
- EC2
- Nginx
- CloudWatch
- IAM
- OIDC
- S3 remote state
- Git
- GitHub
- GitHub Actions
- CI pipelines
- Troubleshooting IAM permissions

## Project Status

Infrastructure deployment and CI testing completed successfully.

Terraform currently reports:

```text
No changes.
Your infrastructure matches the configuration.
```
