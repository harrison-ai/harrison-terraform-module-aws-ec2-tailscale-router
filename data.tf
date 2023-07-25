data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Tailscale Router
# ------------------------------------------------------------------------------

# Block if required SSM parameters don't exist 
data "aws_ssm_parameter" "tailscale_oauth_client_id_ssm_param" {
  name = var.tailscale_oauth_client_id_ssm_param
}
data "aws_ssm_parameter" "tailscale_oauth_client_secret_ssm_param" {
  name = var.tailscale_oauth_client_secret_ssm_param
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = [var.instance_architecture]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_iam_policy_document" "router_access" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:ssm:${local.region}:${local.account_id}:${var.tailscale_oauth_client_id_ssm_param}",
      "arn:aws:ssm:${local.region}:${local.account_id}:${var.tailscale_oauth_client_secret_ssm_param}"
    ]
  }
}

data "aws_iam_policy_document" "router_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


# User data script that runs when the tailscale router stats
data "template_file" "user_data" {
  template = file("${path.module}/userdata.sh")
  vars = {
    tailscale_oauth_client_id_ssm_param     = var.tailscale_oauth_client_id_ssm_param
    tailscale_oauth_client_secret_ssm_param = var.tailscale_oauth_client_secret_ssm_param
    tailscale_tags                          = jsonencode(var.tailscale_tags)
    tailscale_machine_name                  = var.tailscale_machine_name
    tailscale_tailnet                       = var.tailscale_tailnet
    advertised_routes                       = join(",", var.advertised_routes)
  }
}

# ------------------------------------------------------------------------------
# Refresh Lambda
# ------------------------------------------------------------------------------
data "archive_file" "refresh_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = local.lambda_package
}

data "aws_iam_policy_document" "refresh_lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "refresh_lambda" {
  statement {
    sid    = "AllowAutoScalingGroupDescribe"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeInstanceRefreshes",
    ]

    resources = ["*"]
  }

  statement {
    sid     = "AllowAutoScalingGroupInstanceRefresh"
    effect  = "Allow"
    actions = ["autoscaling:StartInstanceRefresh"]

    resources = [
      aws_autoscaling_group.router.arn,
    ]
  }

  statement {
    sid       = "AllowLaunchTemplateDescribe"
    effect    = "Allow"
    actions   = ["ec2:DescribeLaunchTemplateVersions"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowLaunchTemplateCreateModify"
    effect = "Allow"

    actions = [
      "ec2:CreateLaunchTemplateVersion",
      "ec2:ModifyLaunchTemplate",
    ]

    resources = [
      aws_launch_template.router.arn
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.refresh.function_name}:*",
    ]
  }
}
