locals {
  ec2_random_names = ["ec2", "key_pair", "sg"]
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

data "aws_ami_ids" "linux" {
  owners = ["amazon"]
  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

#output "amis" { value = data.aws_ami_ids.linux.* }


module "ec2_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name                        = format("ssh-%s", random_pet.ec2["sg"].id)
  description = "Security group for SSH"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                        = random_pet.ec2["ec2"].id
  ami                         = data.aws_ami_ids.linux.ids[0]
  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.ec2_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  tags = var.tags
}

output "ec2" { value = module.ec2_instance.* }

