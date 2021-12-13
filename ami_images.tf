
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


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*bionic*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#output "ubuntu_amis" { value = data.aws_ami.ubuntu.* }


locals {
  images = { ubuntu : data.aws_ami.ubuntu.id
    amazon : data.aws_ami_ids.linux.ids[0]
  }
}

