# Marriott Infrastructure Repository

This repository contains infrastructure as code for AWS using Terraform modules orchestrated by Terragrunt.

## Infrastructure Layout

- `modules/`
  - Reusable Terraform modules.
  - Current modules include: `eks/`, `rds/`, `vpc/`.
- `terragrunt/`
  - Environment and region orchestration layer.
  - Uses shared configuration in:
    - `terragrunt/root.hcl`
    - `terragrunt/common.hcl`
    - `terragrunt/_envcom/*.hcl`
  - Environment folders include `dev/`, `perf/`, `qa/`, `staging/`, `prod/`.

## How Configuration Is Structured

Terragrunt stack files (for example `terragrunt/<env>/<region>/<module>/terragrunt.hcl`) merge:

1. Root/shared settings from `root.hcl` and `common.hcl`
2. Environment values from `env.hcl`
3. Region values from `region.hcl`
4. Module defaults from `_envcom/<module>.hcl`
5. Environment-specific overrides in each leaf `terragrunt.hcl`

This keeps module logic reusable while allowing per-environment and per-region customization.

## Prerequisites

Install and configure:

- Terraform
- Terragrunt
- AWS CLI
- Valid AWS credentials/profile with permissions for the target environment

## Common Workflows

Run commands from the repository root unless noted.

### 1) Validate Terragrunt HCL (no backend/init required)

Use this to validate structure and references quickly:

```bash
terragrunt hcl validate --working-dir terragrunt/dev
terragrunt hcl validate --working-dir terragrunt/prod
```

### 2) Plan a Specific Stack

Run from a leaf stack directory:

```bash
cd terragrunt/dev/us-east-2/eks
terragrunt plan
```

### 3) Apply a Specific Stack

```bash
cd terragrunt/dev/us-east-2/vpc
terragrunt apply
```

### 4) Destroy a Specific Stack (use carefully)

```bash
cd terragrunt/dev/us-east-2/redis
terragrunt destroy
```

## Recommended Deployment Order

Within an environment/region, apply in dependency order:

1. `vpc`
2. `eks` / `rds` / other services that depend on networking
3. supporting services (`ecr`, `s3`, `alb`, etc.) as needed

