##################################################################
# Creates IPv4 Internet Gateway (if Internet Access is Required) #
##################################################################

resource "aws_internet_gateway" "main" {
  count  = var.network_enable_internet ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.network_tags_name
  }
}

##############################################################################
# Creates IPv6 Egress-Only Internet Gateway (if Internet Access is Required) #
##############################################################################

resource "aws_egress_only_internet_gateway" "main" {
  count  = var.network_enable_internet && var.network_enable_ipv6 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.network_tags_name
  }
}

##################################################################
# Creates Network Address Translation (NAT) Gateway (if Enabled) #
##################################################################

resource "aws_eip" "nat_gateway" {
  count      = var.network_enable_nat && length(var.subnets_public) > 0 ? 1 : 0
  depends_on = [aws_internet_gateway.main]
  domain     = "vpc"

  tags = {
    Name = "${var.network_tags_name}-nat-gateway"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = one(aws_eip.nat_gateway).id
  count         = var.network_enable_nat && length(var.subnets_public) > 0 ? 1 : 0
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = var.network_tags_name
    Zone = aws_subnet.public[0].availability_zone
  }
}
