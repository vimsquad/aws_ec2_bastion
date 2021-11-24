data "aws_availability_zones" "available" { state = "available" }

resource "random_pet" "vpc" {}


locals {
  cidr_block      = var.cidr_block
  cidr_subnets    = cidrsubnets(local.cidr_block, 8, 8)
  private_subnets = [local.cidr_subnets[0]]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = random_pet.vpc.id
  cidr = local.cidr_block

  azs             = slice(data.aws_availability_zones.available.names, 0, length(local.cidr_subnets))
  private_subnets = local.private_subnets
  public_subnets  = [local.cidr_subnets[1]]

  enable_vpn_gateway     = false
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = var.tags

}

output "vpc" { value = module.vpc.* }

