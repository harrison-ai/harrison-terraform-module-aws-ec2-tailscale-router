# -----------------------------------------------------------------------------
# Tailscale Routers
# -----------------------------------------------------------------------------

resource "aws_iam_role" "router" {
  name               = local.base_name
  assume_role_policy = data.aws_iam_policy_document.router_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.router.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "router" {
  name   = local.base_name
  policy = data.aws_iam_policy_document.router_access.json
}

resource "aws_iam_role_policy_attachment" "router_role" {
  role       = aws_iam_role.router.name
  policy_arn = aws_iam_policy.router.arn
}

resource "aws_iam_instance_profile" "router" {
  name = local.base_name
  role = aws_iam_role.router.name
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
