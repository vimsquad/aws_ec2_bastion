Example auto.tfvars file

```
cat dev.auto.tfvars
tags = {
  env : "dev"
  project : "crypt"
}

cidr_block = "10.0.0.0/16"

```


Example SSH Command

```
ssh -l ec2-user -i secrets/eg-prod-magnetic-python.pem hostname
``
