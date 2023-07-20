locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  resource_prefix  = var.resource_prefix == "" ? "" : "${var.resource_prefix}-"
  resource_suffix  = var.resource_suffix == "" ? "" : "-${var.resource_suffix}"
  base_name        = "${local.resource_prefix}${var.resource_name}${local.resource_suffix}"
  lambda_base_name = "${local.resource_prefix}${var.resource_name}-refresh${local.resource_suffix}"
  lambda_package   = "${path.root}/.terraform/harrison-lambda-builds/refresh.zip"
}
