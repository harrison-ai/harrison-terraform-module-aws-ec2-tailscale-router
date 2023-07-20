# A Terraform Module to deploy AWS EC2 Tailscale routers

This module configures AWS EC2 instances to act as Tailscale router as discussed [here](https://tailscale.com/kb/1019/subnets/).

The AWS EC2 instances are configured in an Autoscaling Group which are refreshed by a Lambda on a set interval.

You must configure an OIDC client in the Tailscale console and install the ID and Secret into the SSM parameters.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_event_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.refresh_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.refresh_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.refresh_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.refresh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [archive_file.refresh_lambda_function](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.refresh_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.refresh_lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advertised_routes"></a> [advertised\_routes](#input\_advertised\_routes) | Routes that this tailscale router should handle. | `list(string)` | n/a | yes |
| <a name="input_instance_architecture"></a> [instance\_architecture](#input\_instance\_architecture) | EC2 instance architecture. Usually x86\_64 or arm64. | `string` | `"arm64"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of EC2 instances the autoscaling group will bring online. | `number` | `2` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Size of the instance to run the Tailscale router. | `string` | `"t4g.micro"` | no |
| <a name="input_refresh_lambda_interval"></a> [refresh\_lambda\_interval](#input\_refresh\_lambda\_interval) | AWS schedule expression to fire the auto scaling refresh lambda. | `string` | `"rate(14 days)"` | no |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Resource name for AWS resources. | `string` | `"tailscale-router"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Resource prefix for AWS resources. | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Resource suffix for AWS resources. | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs wher ethe tailscale router resides. | `list(any)` | n/a | yes |
| <a name="input_tailscale_machine_name"></a> [tailscale\_machine\_name](#input\_tailscale\_machine\_name) | Tailscale machine name override. | `string` | n/a | yes |
| <a name="input_tailscale_oauth_client_id_ssm_param"></a> [tailscale\_oauth\_client\_id\_ssm\_param](#input\_tailscale\_oauth\_client\_id\_ssm\_param) | Tailscale OAuth client ID SSM parameter path. | `string` | n/a | yes |
| <a name="input_tailscale_oauth_client_secret_ssm_param"></a> [tailscale\_oauth\_client\_secret\_ssm\_param](#input\_tailscale\_oauth\_client\_secret\_ssm\_param) | Tailscale OAuth client secret SSM parameter path. | `string` | n/a | yes |
| <a name="input_tailscale_tags"></a> [tailscale\_tags](#input\_tailscale\_tags) | Tailscale Tags for the device. Must match the Tailscale OAuth client. | `list(string)` | n/a | yes |
| <a name="input_use_spot_instance"></a> [use\_spot\_instance](#input\_use\_spot\_instance) | Boolean if to use a spot instance as the capacity type. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the Tailscale router resides. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
