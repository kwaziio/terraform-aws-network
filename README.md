# Terraform AWS Network Module by KWAZI

Terraform Module for Creating a Configurable Network Stack on Amazon Web Services (AWS)

## Getting Started

> NOTE: This section assumes that you have Terraform experience, have already created an AWS account, and have already configured programmatic access to that account via access token, Single-Sign On (SSO), or AWS Identity and Access Management (IAM) role. If you need help, [checkout our website](https://www.kwazi.io).

The simplest way to get started is to create a `main.tf` file with the minimum configuration options. You can use the following as a template:

```HCL
###########################
# Terraform Configuration #
###########################

terraform {
  required_version = ">= 1.6.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21"
    }
  }
}

##############################
# AWS Provider Configuration #
##############################

provider "aws" {
  // DO NOT HARDCODE CREDENTIALS (Use Environment Variables)
}

##############################################
# Example Terraform AWS Network Module Usage #
##############################################

module "terraform_aws_network" {
  source = "../../"

  network_primary_cidr_block = "10.X.0.0/16"
  network_tags_name          = "REPLACE_WITH_NETWORK_NAME"
  network_trusted_ipv4_cidrs = ["REPLACE_WITH_VPN_IP/32"]

  subnets_private = [
    {
      cidr = "10.X.0.0/19",
      name = "private-a",
      zone = "a",
    },
    {
      cidr = "10.X.32.0/19",
      name = "private-b",
      zone = "b",
    },
    {
      cidr = "10.X.64.0/19",
      name = "private-c",
      zone = "c",
    },
  ]

  subnets_public = [
    {
      cidr = "10.X.192.0/20",
      name = "public-a",
      zone = "a",
    },
    {
      cidr = "10.X.208.0/20",
      name = "public-b",
      zone = "b",
    },
    {
      cidr = "10.X.224.0/20",
      name = "public-c",
      zone = "c",
    },
  ]
}

```

In the example above, you should replace the following templated values:

Placeholder | Description
--- | ---
`REPLACE_WITH_NETWORK_NAME` | Replace this w/ a Network Name that Makes Sense for Your Use Case
`REPLACE_WITH_VPN_IP` | Replace this w/ the IP Address of Your VPN or Personal Device
`X` | Replace the Second Octet Value w/ Any Number from 0 to 255

## Need Help?

Working in a strict environment? Struggling to make design decisions you feel comfortable with? Want help from an expert that you can rely on -- one who won't abandon you when the job is finished?

Check us out at [https://www.kwazi.io](https://www.kwazi.io).

## Designing a Deployment

Before launching this module, your team should agree on the following decision points:

1. Will you need to disable IPv6 support?
1. Will you need to disable all internet access?
1. Will you require Network Address Translation (NAT) support?
1. Will you have any CIDR limitations enforced by your organization?
1. Will you need to restrict outbound requests by destination CIDR?
1. Will you need to disable DNS support?
1. Will you need to use non-standard ports for SSH and RDP?
1. Will you need dedicated hardware?

### Will you need to disable IPv6 support?

Leveraging IPv6 can lead to significant savings when working with AWS, because hosted resources can take advantage of Egress-Only Internet Gateways. These gateways allow resources to access the internet and receive responses, but explicitly block externally-initiated requests.

Using Egress-Only Internet Gateways reduces (and occasionally eliminates) the need for Network Address Translation (NAT) Gateways, which have both hourly and usage based fees.

Unless you're part of an organization that explicitly prohibits IPv6 support, then you probably want to have this feature enabled here. If you _do_ need to disable IPv6 support, you can do so by setting the following variable:

```HCL
network_enable_ipv6 = false
```

### Will you need to disable all internet access?

If your resources will need to reach the internet for any reason at all -- including for tasks such as downloading operating system updates -- and your team isn't planning on leveraging a dedicated Transit Gateway or external proxy setup, then the answer to this question should be _no_.

If the answer is _yes_, then you can disable internet access by setting the following variable:

```HCL
network_enable_internet = false
```

> NOTE: By default, only resources deployed to the _public_ subnets created by this module are capable of receiving direct communication from the public internet. Disabling internet access here is more about preventing traffic from leaving the network than it is about protecting resources from unsolicited traffic from outside sources.

### Will you require Network Address Translation (NAT) support?

If resources in your private subnet (i.e., resources without a public IP address) will need to communicate with the public internet for any reason and if IPv6 is disabled for your environment, then the answer to this question should be _yes_. If you're only deploying resources to a public subnet, then the answer to this question should be _no_.

To enable NAT support, set the following variable:

```HCL
network_nat_enabled = true
```

> NOTE: Network Address Translation (NAT) can still be useful when IPv6 is enabled, specifically when dealing with applications that don't support IPv6.

### Will you have any CIDR limitations enforced by your organization?

If your team is small and you don't need to worry about organizational restrictions, sticking with our basic recommendations should be fine. If you _do_ need to work around predefined limitations, then just remember the following:

* VPC CIDRs Should NOT Overlap w/ Existing Networks (if Possible)
* Each VPC in AWS Supports 1 Primary and Up to 4 Secondary CIDR Blocks
* The Largest CIDR Range for a VPC is /16
* The Smallest CIDR Range for a VPC is /28

If you're stuck dealing with a complex setup, [reach out to us for help](https://www.kwazi.io).

### Will you need to restrict outbound requests by destination CIDR?

For most teams, the answer to this question will be no. Typically, we only see this requirement while working with organizations that have extremely strict regulatory requirements. If you're one of those groups, you can limit this by setting the following variables:

```HCL
network_egress_cidr_block_ipv4 = "0.0.0.0/0" # Replace w/ Required IPv4 CIDR
network_egress_cidr_block_ipv6 = "::/0"      # Replace w/ Required IPv6 CIDR
```

If you want more advice on cleaner ways to deal with air-tight regulatory environments, [we can help](https://www.kwazi.io).

### Will you need to disable DNS support?

There is rarely a need to disable DNS support for a VPC as it has no cost, but if you do need to disable DNS, you can do so by updating the following variables:

```HCL
network_enable_dns_hostnames = false
network_enable_dns_support   = false
```

### Will you need to use non-standard ports for SSH and RDP?

Most of the teams we work with leverage standard ports for SSH and RDP, but obfuscating these ports is also a common practice. If your team needs to change these, you can update the following two variables:

```HCL
network_default_rdp_port = 3389 # Replace w/ Required RDP Port
network_default_ssh_port = 22   # Replace w/ Required SSH Port
```

### Will you need dedicated hardware?

Be warned, make sure that you ABSOLUTELY need this before changing this setting. Choosing to use dedicated hardware rather than shared resources (the default configuration for AWS) is _extremely_ expensive. We've set this to the default value, but changing it here is an option -- one that we almost always highly discourage.

## Major Created Resources

The following table lists resources that this module may create in AWS, accompanied by conditions for when they will or will not be created:

Resource Name | Creation Condition
--- | ---
Egress-Only Internet Gateway | When `network_enable_internet` and `network_enable_ipv6` are `true`
Elastic IP Address | When `network_enable_internet` and `network_enable_nat` are `true`
Internet Gateway | When `network_enable_internet` is `true`
NAT Gateway | When `network_enable_internet` and `network_enable_nat` are `true`
Network Access Control List (NACL) | When `subnets_private` or `subnets_private` Have at Least 1 Item
Route Table(s) | When `subnets_private` or `subnets_private` Have at Least 1 Item
Security Group(s) | Always
Subnet(s) | When `subnets_private` or `subnets_private` Have at Least 1 Item
VPC Endpoint | Always
VPC | Always

## Usage Examples

The following examples are provided as guidance:

* [examples/complex](examples/complex/main.tf)
* [examples/minimal](examples/minimal/main.tf)
