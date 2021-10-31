module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = var.vpc_cidr
  name = "${var.stack_prefix}-vpc"

  azs = var.availability_zones
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 0),
    cidrsubnet(var.vpc_cidr, 4, 1),
    cidrsubnet(var.vpc_cidr, 4, 2)
  ]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 3),
    cidrsubnet(var.vpc_cidr, 4, 4),
    cidrsubnet(var.vpc_cidr, 4, 5)
  ]

  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  tags = {
    controller = "terraform"
    stack      = "${var.stack_prefix}-vpc"
  }
}