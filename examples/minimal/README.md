# Minimal Usage Example

This example is intended to show a standard use case for this module with the least amount of recommended customization.

```HCL
##############################################
# Example Terraform AWS Network Module Usage #
##############################################

module "terraform_aws_network" {
  source = "../../"

  network_primary_cidr_block = "10.0.0.0/16"
  network_tags_name          = "example-minimal"
  network_trusted_ipv4_cidrs = ["0.0.0.0/0"]

  subnets_private = [
    {
      cidr = "10.0.0.0/19",
      name = "private-a",
      zone = "a",
    },
    {
      cidr = "10.0.32.0/19",
      name = "private-b",
      zone = "b",
    },
    {
      cidr = "10.0.64.0/19",
      name = "private-c",
      zone = "c",
    },
  ]

  subnets_public = [
    {
      cidr = "10.0.192.0/20",
      name = "public-a",
      zone = "a",
    },
    {
      cidr = "10.0.208.0/20",
      name = "public-b",
      zone = "b",
    },
    {
      cidr = "10.0.224.0/20",
      name = "public-c",
      zone = "c",
    },
  ]
}
```

## Executing Example Deployment

The following example is provided as guidance, but can also be used for integration testing:

* [https://github.com/kwaziio/terraform-aws-network/tree/main/examples/minimal](https://github.com/kwaziio/terraform-aws-network/tree/main/examples/minimal)

### Deploying Complex Minimal as Integration Test

The following commands will initialize and deploy the infrastructure for the minimal example:

```SHELL
terraform -chdir=examples/minimal init -reconfigure
terraform -chdir=examples/minimal apply
```

### Destroying Minimal Example After Integration Test

The following command will destroy any resources created while deploying the minimal example:

```SHELL
terraform -chdir=examples/minimal destroy
```
