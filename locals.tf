locals {
  environment = terraform.workspace

  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = "AutoScaling"
  }

  instance_name = "${local.environment}-asg-instance"
}
