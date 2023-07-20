# -----------------------------------------------------------------------------
# Tailscale Routers
# -----------------------------------------------------------------------------
resource "aws_iam_instance_profile" "this" {
  name = local.base_name
  role = aws_iam_role.this.name
}
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "this" {
  name = local.base_name
  inline_policy {
    name = "allow-read-tailscale-auth-key-ssm-param"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:ssm:${local.region}:${local.account_id}:${var.tailscale_oauth_client_id_ssm_param}",
            "arn:aws:ssm:${local.region}:${local.account_id}:${var.tailscale_oauth_client_secret_ssm_param}"
          ]
        },
      ]
    })
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

# -----------------------------------------------------------------------------
# Refresh Lambda
# -----------------------------------------------------------------------------

resource "aws_iam_role" "refresh_lambda" {
  name               = local.lambda_base_name
  assume_role_policy = data.aws_iam_policy_document.refresh_lambda_assume_role.json
  description        = "Tailscale router refresh lambda role"
}

resource "aws_iam_role_policy" "refresh_lambda" {
  name   = local.lambda_base_name
  policy = data.aws_iam_policy_document.refresh_lambda.json
  role   = aws_iam_role.refresh_lambda.id
}
