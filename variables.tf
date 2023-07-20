variable "resource_prefix" {
  type        = string
  description = "Resource prefix for AWS resources."
  default     = ""
}

variable "resource_name" {
  type        = string
  description = "Resource name for AWS resources."
  default     = "tailscale-router"
}

variable "resource_suffix" {
  type        = string
  description = "Resource suffix for AWS resources."
  default     = ""
}

variable "tailscale_machine_name" {
  type        = string
  description = "Tailscale machine name override."
}

variable "tailscale_oauth_client_id_ssm_param" {
  type        = string
  description = "Tailscale OAuth client ID SSM parameter path."
}

variable "tailscale_oauth_client_secret_ssm_param" {
  type        = string
  description = "Tailscale OAuth client secret SSM parameter path."
}

variable "tailscale_tags" {
  type        = list(string)
  description = "Tailscale Tags for the device. Must match the Tailscale OAuth client."
}

variable "advertised_routes" {
  type        = list(string)
  description = "Routes that this tailscale router should handle."
}

variable "instance_type" {
  type        = string
  description = "Size of the instance to run the Tailscale router."
  default     = "t4g.micro"
}

variable "instance_architecture" {
  type        = string
  description = "EC2 instance architecture. Usually x86_64 or arm64."
  default     = "arm64"
}

variable "use_spot_instance" {
  type        = bool
  description = "Boolean if to use a spot instance as the capacity type."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the Tailscale router resides."
}

variable "subnet_ids" {
  type        = list(any)
  description = "Subnet IDs wher ethe tailscale router resides."
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances the autoscaling group will bring online."
  default     = 2
}

variable "refresh_lambda_interval" {
  type        = string
  description = "AWS schedule expression to fire the auto scaling refresh lambda."
  default     = "rate(14 days)"
}
