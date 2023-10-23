###############################
# Locally-Available Variables #
###############################

locals {
  network_cidrs = concat([var.network_primary_cidr_block], var.network_secondary_cidr_blocks)
}

##############################################################
# Creates AWS Virtual Private Cloud (VPC) [Network] Resource #
##############################################################

resource "aws_vpc" "main" {
  assign_generated_ipv6_cidr_block     = var.network_enable_ipv6
  cidr_block                           = var.network_primary_cidr_block
  enable_dns_hostnames                 = var.network_enable_dns_hostnames
  enable_dns_support                   = var.network_enable_dns_support
  enable_network_address_usage_metrics = var.network_enable_metrics
  instance_tenancy                     = var.network_instance_tenancy

  tags = {
    Name = var.network_tags_name
  }
}

###############################################################
# Assigns Optional Secondary IPv4 CIDR Blocks (if Applicable) #
###############################################################

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  cidr_block = var.network_secondary_cidr_blocks[count.index]
  count      = length(var.network_secondary_cidr_blocks)
  vpc_id     = aws_vpc.main.id
}
