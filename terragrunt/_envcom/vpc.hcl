# Shared VPC defaults for all environments
locals {
  vpc_common_inputs = {
    # NAT Gateway configuration
    enable_nat_gateway     = true
    single_nat_gateway     = false
    one_nat_gateway_per_az = true

    # DNS configuration
    enable_dns_hostnames = true
    enable_dns_support   = true

    # VPC Flow Logs
    enable_flow_log            = true
    flow_log_retention_in_days = 7

    create_database_subnet_group       = true
    create_database_subnet_route_table = true

    # EKS-related subnet tags
    enable_eks_tags = true

    # Additional subnet tags
    public_subnet_tags = {
      Type = "public"
    }

    private_subnet_tags = {
      Type = "private"
    }
  }
}
