terraform {
  required_version = ">= 1.0"
}

# Reference the official VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Database subnets (optional)
  database_subnets                   = var.database_subnet_cidrs
  create_database_subnet_group       = var.create_database_subnet_group
  create_database_subnet_route_table = var.create_database_subnet_route_table

  # NAT Gateway configuration
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # DNS configuration
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # VPC Flow Logs
  enable_flow_log                                 = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role             = var.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.enable_flow_log
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_retention_in_days

  # EKS specific tags
  public_subnet_tags = merge(
    var.tags,
    var.public_subnet_tags,
    var.enable_eks_tags ? {
      "kubernetes.io/role/elb" = "1"
    } : {}
  )

  private_subnet_tags = merge(
    var.tags,
    var.private_subnet_tags,
    var.enable_eks_tags ? {
      "kubernetes.io/role/internal-elb" = "1"
    } : {}
  )

  # Tags
  tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "vpc"
    }
  )
}
