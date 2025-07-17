resource "aws_launch_template" "router" {
  name          = local.base_name
  description   = "Launch template for Tailscale router"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    tailscale_oauth_client_id_ssm_param     = var.tailscale_oauth_client_id_ssm_param
    tailscale_oauth_client_secret_ssm_param = var.tailscale_oauth_client_secret_ssm_param
    tailscale_tags                          = jsonencode(var.tailscale_tags)
    tailscale_machine_name                  = var.tailscale_machine_name
    tailscale_tailnet                       = var.tailscale_tailnet
    advertised_routes                       = join(",", var.advertised_routes)
  }))

  vpc_security_group_ids = [aws_security_group.router.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.router.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = local.base_name
    }
  }

  dynamic "instance_market_options" {
    for_each = var.use_spot_instance ? [1] : []
    content {
      market_type = "spot"
    }
  }
}

resource "aws_autoscaling_group" "router" {
  name                = local.base_name
  desired_capacity    = var.instance_count
  min_size            = 0
  max_size            = var.instance_count
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.router.id
    version = "$Latest"
  }
}

resource "aws_security_group" "router" {
  name        = local.base_name
  vpc_id      = var.vpc_id
  description = "Security group for the Tailscale router."
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.router.id
  type              = "egress"
  description       = "Allow all traffic outbound."
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = -1
}
