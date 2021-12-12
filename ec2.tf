locals {
  ec2_instances = ["node1", "node2"]
  ec2_random_names = concat(["key_pair", "sg"], local.ec2_instances)
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



module "ec2_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = format("ssh-%s", random_pet.ec2["sg"].id)
  description = "Security group for SSH"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

}

variable "ec2_size" { type = string }
variable "ami" { type = string }

module "ec2_instance" {
  for_each = toset(local.ec2_instances)
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                        = random_pet.ec2[each.key].id
  ami                         = lookup(local.images, lower(var.ami), "amazon")
  instance_type               = var.ec2_size
  key_name                    = module.key_pair.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.ec2_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  tags                        = var.tags
}

output "ec2" { value = { for x, y in module.ec2_instance: x => y.public_dns } }

