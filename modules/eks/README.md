# EKS Module

Custom Terraform module for deploying AWS EKS clusters.

## Example Usage
[Example](./example)

## Description

This module wraps the official [terraform-aws-modules/eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module to provide a standardized way to deploy EKS clusters in your organization.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

This module uses the AWS provider indirectly through the official EKS module.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| vpc_id | ID of the VPC where the cluster will be deployed | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | `"1.29"` | no |
| cluster_endpoint_public_access | Enable public access to the cluster endpoint | `bool` | `true` | no |
| cluster_endpoint_private_access | Enable private access to the cluster endpoint | `bool` | `true` | no |
| control_plane_subnet_ids | List of subnet IDs for the EKS control plane | `list(string)` | `[]` | no |
| cluster_addons | Map of cluster addon configurations | `any` | See variables.tf | no |
| eks_managed_node_groups | Map of EKS managed node group definitions | `any` | `{}` | no |
| enable_cluster_creator_admin_permissions | Enable admin permissions for the cluster creator | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the EKS cluster |
| cluster_arn | The ARN of the EKS cluster |
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data (sensitive) |
| cluster_name | The name of the EKS cluster |
| cluster_version | The Kubernetes server version for the EKS cluster |
| oidc_provider_arn | ARN of the OIDC Provider for EKS |
| eks_managed_node_groups | Map of all EKS managed node groups created |
| eks_managed_node_groups_autoscaling_group_names | List of autoscaling group names |

## Notes

- This module automatically applies standard tags to all resources
- The official EKS module version is pinned to `~> 20.0`
- OIDC provider is automatically created for IRSA support

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.36.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws_auth"></a> [aws\_auth](#module\_aws\_auth) | terraform-aws-modules/eks/aws//modules/aws-auth | ~> 20.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 21.15.1 |
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | 6.4.0 |
| <a name="module_vpc_cni_pod_identity"></a> [vpc\_cni\_pod\_identity](#module\_vpc\_cni\_pod\_identity) | terraform-aws-modules/eks-pod-identity/aws | 2.7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ami.eks_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of EKS access entries (only valid with API or API\_AND\_CONFIG\_MAP authentication modes) | `map(any)` | `{}` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | EKS authentication mode: API, CONFIG\_MAP, or API\_AND\_CONFIG\_MAP | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_aws_auth_config"></a> [aws\_auth\_config](#input\_aws\_auth\_config) | Configuration for managing the aws-auth configmap | <pre>object({<br/>    manage_aws_auth_configmap = optional(bool, false)<br/>    create_aws_auth_configmap = optional(bool, false)<br/>    aws_auth_roles            = optional(list(any), [])<br/>    aws_auth_users            = optional(list(any), [])<br/>    aws_auth_accounts         = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Retention in days for the EKS control plane log group | `number` | `null` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | List of control plane log types to enable | `list(string)` | `[]` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Enable private access to the cluster endpoint | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Enable public access to the cluster endpoint | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Additional tags for the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for the EKS cluster | `string` | `"1.29"` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | List of subnet IDs for the EKS control plane (if different from subnet\_ids) | `list(string)` | `[]` | no |
| <a name="input_core_addons_settings"></a> [core\_addons\_settings](#input\_core\_addons\_settings) | Unified settings for core addons (versions, configuration\_values, resolve\_conflicts, and timeouts). | `map(any)` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions | `any` | `{}` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Enable admin permissions for the cluster creator | `bool` | `true` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Enable IAM Roles for Service Accounts (IRSA) | `bool` | `false` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Map of self-managed node group definitions. If ami\_id is not specified, the latest EKS-optimized AMI for the cluster version will be used automatically | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cni_identity_mode"></a> [vpc\_cni\_identity\_mode](#input\_vpc\_cni\_identity\_mode) | The authentication mode for vpc-cni: 'irsa' or 'pod\_identity' | `string` | `"pod_identity"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the EKS cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the EKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes server version for the EKS cluster |
| <a name="output_core_addons"></a> [core\_addons](#output\_core\_addons) | Map of core addons managed by the EKS module |
| <a name="output_default_ami_id"></a> [default\_ami\_id](#output\_default\_ami\_id) | The default EKS-optimized AMI ID used for self-managed nodes |
| <a name="output_default_ami_name"></a> [default\_ami\_name](#output\_default\_ami\_name) | The name of the default EKS-optimized AMI |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | Compact summary of EKS managed node groups |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | Security group ID attached to the EKS worker nodes |
| <a name="output_oidc_provider"></a> [oidc\_provider](#output\_oidc\_provider) | OIDC provider URL for EKS |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC Provider for EKS |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Compact summary of self-managed node groups |
| <a name="output_vpc_cni_iam_role_arn"></a> [vpc\_cni\_iam\_role\_arn](#output\_vpc\_cni\_iam\_role\_arn) | The IAM role ARN used by the vpc-cni (IRSA or Pod Identity) |
| <a name="output_vpc_cni_identity_mode"></a> [vpc\_cni\_identity\_mode](#output\_vpc\_cni\_identity\_mode) | The identity mode currently active for the vpc-cni |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID of the EKS cluster |
<!-- END_TF_DOCS -->