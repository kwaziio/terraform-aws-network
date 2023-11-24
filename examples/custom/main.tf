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

  network_enable_nat         = false
  network_primary_cidr_block = "10.0.0.0/16"
  network_tags_name          = "example-custom"
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

#########################################################
# Default Amazon Web Services (AWS) Session Information #
#########################################################

data "aws_region" "current" {}

###########################################################
# Creates Unique NAT Gateway for Availability Zone (AZ) A #
###########################################################

data "aws_subnets" "public_a" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.id}a"]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }

  filter {
    name   = "vpc-id"
    values = [module.terraform_aws_network.network_id]
  }
}

data "aws_subnets" "private_a" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.id}a"]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }

  filter {
    name   = "vpc-id"
    values = [module.terraform_aws_network.network_id]
  }
}

resource "aws_eip" "nat_gateway_a" {
  depends_on = [module.terraform_aws_network]
  domain     = "vpc"

  tags = {
    Name = "example-custom-nat-gateway-a"
  }
}

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.nat_gateway_a.id
  subnet_id     = data.aws_subnets.public_a.ids[0]

  tags = {
    Name = "example-custom-nat-gateway-a"
    Zone = "a"
  }
}

data "aws_route_table" "private_a" {
  count     = length(data.aws_subnets.private_a.ids)
  subnet_id = data.aws_subnets.private_a.ids[count.index]
}

resource "aws_route" "private_nat_gateway_a" {
  count                  = length(data.aws_route_table.private_a)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.a.id
  route_table_id         = data.aws_route_table.private_a[count.index].id
}

###########################################################
# Creates Unique NAT Gateway for Availability Zone (AZ) B #
###########################################################

data "aws_subnets" "public_b" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.id}b"]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }

  filter {
    name   = "vpc-id"
    values = [module.terraform_aws_network.network_id]
  }
}

data "aws_subnets" "private_b" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.id}b"]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }

  filter {
    name   = "vpc-id"
    values = [module.terraform_aws_network.network_id]
  }
}

resource "aws_eip" "nat_gateway_b" {
  depends_on = [module.terraform_aws_network]
  domain     = "vpc"

  tags = {
    Name = "example-custom-nat-gateway-b"
  }
}

resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.nat_gateway_a.id
  subnet_id     = data.aws_subnets.public_b.ids[0]

  tags = {
    Name = "example-custom-nat-gateway-b"
    Zone = "b"
  }
}

data "aws_route_table" "private_b" {
  count     = length(data.aws_subnets.private_b.ids)
  subnet_id = data.aws_subnets.private_b.ids[count.index]
}

resource "aws_route" "private_nat_gateway_b" {
  count                  = length(data.aws_route_table.private_b)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.a.id
  route_table_id         = data.aws_route_table.private_b[count.index].id
}

###########################################################
# Creates Unique NAT Gateway for Availability Zone (AZ) C #
###########################################################

data "aws_subnets" "public_c" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.id}c"]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }

  filter {
    name   = "vpc-id"
    values = [module.terraform_aws_network.network_id]
  }
}

data "aws_subnets" "private_c" {
  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.id}c"]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }

  filter {
    name   = "vpc-id"
    values = [module.terraform_aws_network.network_id]
  }
}

resource "aws_eip" "nat_gateway_c" {
  depends_on = [module.terraform_aws_network]
  domain     = "vpc"

  tags = {
    Name = "example-custom-nat-gateway-c"
  }
}

resource "aws_nat_gateway" "c" {
  allocation_id = aws_eip.nat_gateway_a.id
  subnet_id     = data.aws_subnets.public_a.ids[0]

  tags = {
    Name = "example-custom-nat-gateway-c"
    Zone = "c"
  }
}

data "aws_route_table" "private_c" {
  count     = length(data.aws_subnets.private_c.ids)
  subnet_id = data.aws_subnets.private_c.ids[count.index]
}

resource "aws_route" "private_nat_gateway_c" {
  count                  = length(data.aws_route_table.private_c)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.c.id
  route_table_id         = data.aws_route_table.private_c[count.index].id
}
