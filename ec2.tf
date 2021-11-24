locals {
  ec2_random_names = ["ec2", "key_pair"]
}

resource "random_pet" "ec2" { for_each = toset(local.ec2_random_names) }

module "key_pair" {
  source  = "cloudposse/key-pair/aws"
  version = "0.18.2"
  # insert the 14 required variables here
  namespace             = "eg"
  stage                 = "prod"
  name                  = random_pet.ec2["key_pair"].id
  ssh_public_key_path   = "./secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}

data "aws_ami_ids" "ubuntu" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/ubuntu-*-*-amd64-server-*"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                        = random_pet.ec2["ec2"].id
  ami                         = data.aws_ami_ids.ubuntu.ids[0]
  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_name
  monitoring                  = true
  vpc_security_group_ids      = []
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = true

  tags = var.tags
}

output "ec2" { value = module.ec2_instance.* }

