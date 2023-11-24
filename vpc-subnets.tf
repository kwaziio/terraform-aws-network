################################################################
# Creates Private Subnet(s) in Created Network (if Applicable) #
################################################################

locals {
  private_subnet_range_cidr = var.network_enable_ipv6 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 1, 1) : null
}

resource "aws_subnet" "private" {
  assign_ipv6_address_on_creation = var.network_enable_ipv6
  availability_zone               = "${data.aws_region.current.id}${lower(var.subnets_private[count.index].zone)}"
  cidr_block                      = var.subnets_private[count.index].cidr
  count                           = length(var.subnets_private)
  ipv6_cidr_block                 = var.network_enable_ipv6 ? cidrsubnet(local.private_subnet_range_cidr, 7, count.index) : null
  map_public_ip_on_launch         = false
  vpc_id                          = aws_vpc.main.id

  depends_on = [
    aws_vpc.main,
    aws_vpc_ipv4_cidr_block_association.secondary,
  ]

  tags = {
    Name = "${var.network_tags_name}-${var.subnets_private[count.index].name}"
    Type = "private"
    Zone = "${data.aws_region.current.id}${lower(var.subnets_private[count.index].zone)}"
  }
}

resource "aws_network_acl_association" "private" {
  count          = length(aws_subnet.private)
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.subnets_private)
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}

###############################################################
# Creates Public Subnet(s) in Created Network (if Applicable) #
###############################################################

locals {
  public_subnet_range_cidr = var.network_enable_ipv6 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 1, 0) : null
}

resource "aws_subnet" "public" {
  assign_ipv6_address_on_creation = var.network_enable_ipv6
  availability_zone               = "${data.aws_region.current.id}${lower(var.subnets_public[count.index].zone)}"
  cidr_block                      = var.subnets_public[count.index].cidr
  count                           = length(var.subnets_public)
  ipv6_cidr_block                 = var.network_enable_ipv6 ? cidrsubnet(local.public_subnet_range_cidr, 7, count.index) : null
  map_public_ip_on_launch         = true
  vpc_id                          = aws_vpc.main.id

  depends_on = [
    aws_vpc.main,
    aws_vpc_ipv4_cidr_block_association.secondary,
  ]

  tags = {
    Name = "${var.network_tags_name}-${var.subnets_public[count.index].name}"
    Type = "public"
    Zone = "${data.aws_region.current.id}${lower(var.subnets_public[count.index].zone)}"
  }
}

resource "aws_network_acl_association" "public" {
  count          = length(aws_subnet.public)
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.subnets_public)
  route_table_id = one(aws_route_table.public).id
  subnet_id      = aws_subnet.public[count.index].id
}
