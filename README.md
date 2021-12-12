Example auto.tfvars file

```
cat dev.auto.tfvars
tags = {
  env : "dev"
  project : "training"
}

cidr_block = "10.0.0.0/16"

ec2_size = "m5a.large"

ami = "ubuntu"

```


Example SSH Command

```
ssh -l ubuntu -i secrets/*.pem hostname
```
