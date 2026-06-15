# RDS Module (Aurora PostgreSQL with DR)

This module creates Aurora PostgreSQL and supports cross-region DR using Aurora Global Database.

## Deployment Model

- Primary region:
  - Set `is_primary = true`
  - Set `create_global_cluster = true` for first deployment
- DR region:
  - Set `is_primary = false`
  - Set `global_cluster_identifier` from primary outputs

## Example (Primary)

```hcl
module "rds" {
  source = "../../modules/rds"

  cluster_name           = "marriott-dev-pg"
  is_primary             = true
  create_global_cluster  = true

  vpc_id     = "vpc-xxxx"
  subnet_ids = ["subnet-a", "subnet-b"]

  allowed_cidr_blocks = ["10.0.0.0/8"]
  instance_class      = "db.r6g.large"
  instance_count      = 1
}
```

## Example (DR)

```hcl
module "rds_dr" {
  source = "../../modules/rds"

  cluster_name              = "marriott-dev-pg-dr"
  is_primary                = false
  create_global_cluster     = false
  global_cluster_identifier = "marriott-dev-pg-global"

  vpc_id     = "vpc-yyyy"
  subnet_ids = ["subnet-c", "subnet-d"]

  allowed_cidr_blocks = ["10.0.0.0/8"]
  instance_class      = "db.r6g.large"
  instance_count      = 1
}
```
