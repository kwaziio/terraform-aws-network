########################################
# Updates Default Route Table [Router] #
########################################

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.network_tags_name}-default"
  }
}

####################################################################
# Creates Route Table [Router] for Private Subnets (if Applicable) #
####################################################################

resource "aws_route_table" "private" {
  count  = length(var.subnets_private) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.network_tags_name}-private"
    Type = "private"
  }
}

resource "aws_route" "private_internet_gateway" {
  count                       = var.network_enable_ipv6 && length(var.subnets_private) > 0 ? 1 : 0
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = one(aws_egress_only_internet_gateway.main).id
  route_table_id              = one(aws_route_table.private).id
}

resource "aws_route" "private_internet_gateway" {
  cidr_block             = "0.0.0.0/0"
  count                  = var.network_enable_nat && length(var.subnets_private) > 0 ? 1 : 0
  egress_only_gateway_id = one(aws_egress_only_internet_gateway.main).id
  route_table_id         = one(aws_route_table.private).id
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count           = length(var.subnets_private) > 0 ? 1 : 0
  route_table_id  = one(aws_route_table.private).id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = length(var.subnets_private) > 0 ? 1 : 0
  route_table_id  = one(aws_route_table.private).id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

###################################################################
# Creates Route Table [Router] for Public Subnets (if Applicable) #
###################################################################

resource "aws_route_table" "public" {
  count  = length(var.subnets_public) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.network_tags_name}-public"
    Type = "public"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = length(var.subnets_public) > 0 ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = one(aws_internet_gateway.main).id
  route_table_id         = one(aws_route_table.public).id
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count           = length(var.subnets_public) > 0 ? 1 : 0
  route_table_id  = one(aws_route_table.public).id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count           = length(var.subnets_public) > 0 ? 1 : 0
  route_table_id  = one(aws_route_table.public).id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
