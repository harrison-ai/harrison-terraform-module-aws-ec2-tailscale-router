module "test_router" {
  source = "../../"

  # All AWS resources associated are prefixed with this string.
  resource_prefix = "test"
  # All AWS resources have this in the name and will default to this string.
  resource_name = "tailscale-router"
  # All AWS resources have this suffix. Usually an environment name.
  resource_suffix = "test"

  # VPC ID where to install the EC2 Routers.
  vpc_id = "vpc-123"
  # Subnet IDs where to install the EC2 Routers.
  subnet_ids = [
    "subnet-111111111",
    "subnet-222222222",
    "subnet-333333333"
  ]

  # OAuth Client ID and Secret the router will use. These need to already exist
  # and be populated.
  tailscale_oauth_client_id_ssm_param     = "/tailscale/router-oauth-client-id"
  tailscale_oauth_client_secret_ssm_param = "/tailscale/router-oauth-client-secret"

  # Name of the tailscale machine as it appears in the console. 
  tailscale_machine_name = "test"
  # Name of the tailnet as per the tailscale console
  tailscale_tailnet = "mytailnet"
  # Routes these tailscale routers will advertise.
  advertised_routes = ["192.168.0.0/24"]
  # Tags associated with the OIDC client created in Tailscale.
  tailscale_tags = ["tag:my-tailscale-tag"]

  # Instance type for the EC2 Routers.
  instance_type = "t4g.micro"
  # Instance architecture.
  instance_architecture = "arm64"
  # Whether to use spot instances or not.
  use_spot_instance = true
  # Number of EC2 instances in the autoscaling group.
  instance_count = 2

  # How often to refresh the Autoscaling Group.
  refresh_lambda_interval = "rate(14 days)"
}
