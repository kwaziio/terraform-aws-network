#########################################################################
# Updates Default Network Access Control List (NACL) [Network Firewall] #
#########################################################################

resource "aws_default_network_acl" "main" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  egress {
    action     = "allow"
    cidr_block = var.network_egress_cidr_block_ipv4
    from_port  = 0
    protocol   = -1
    rule_no    = 100
    to_port    = 0
  }

  egress {
    action     = "allow"
    from_port  = 0
    ipv6_cidr_block = var.network_egress_cidr_block_ipv6
    protocol   = -1
    rule_no    = 101
    to_port    = 0
  }

  ingress {
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    protocol   = -1
    rule_no    = 100
    to_port    = 0
  }

  dynamic "ingress" {
    for_each = var.network_enable_ipv6 ? [aws_vpc.main.ipv6_cidr_block] : []

    content {
      action     = "allow"
      from_port  = 0
      ipv6_cidr_block = aws_vpc.main.ipv6_cidr_block
      protocol   = -1
      rule_no    = 101
      to_port    = 0
    }
  }

  dynamic "ingress" {
    for_each = var.network_secondary_cidr_blocks

    content {
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      protocol   = -1
      rule_no    = 102 + ingress.key
      to_port    = 0
    }
  }

  lifecycle {
    ignore_changes = [
      subnet_ids
    ]
  }

  tags = {
    Name = "${var.network_tags_name}-default"
  }
}

#######################################################################################
# Creates Network Access Control List (NACL) [Network Firewall] for Private Subnet(s) #
#######################################################################################

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.network_tags_name}-private"
  }
}

resource "aws_network_acl_rule" "private_egress_all_ipv4" {
  cidr_block     = "0.0.0.0/0"
  count          = length(local.network_cidrs)
  egress         = true
  from_port      = 0
  network_acl_id = aws_network_acl.private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 60 + count.index
  to_port        = 0
}

resource "aws_network_acl_rule" "private_egress_all_ipv6" {
  count           = var.network_enable_ipv6 ? 1 : 0
  egress          = true
  from_port       = 0
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.private.id
  protocol        = "-1"
  rule_action     = "allow"
  rule_number     = 65
  to_port         = 0
}

resource "aws_network_acl_rule" "private_ingress_internal_all_ipv4" {
  cidr_block     = local.network_cidrs[count.index]
  count          = length(local.network_cidrs)
  egress         = false
  from_port      = 0
  network_acl_id = aws_network_acl.private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 50 + count.index
}

resource "aws_network_acl_rule" "private_ingress_internal_all_ipv6" {
  count           = var.network_enable_ipv6 ? 1 : 0
  egress          = false
  from_port       = 0
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.private.id
  protocol        = "-1"
  rule_action     = "allow"
  rule_number     = 55
}

######################################################################################
# Creates Network Access Control List (NACL) [Network Firewall] for Public Subnet(s) #
######################################################################################

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.network_tags_name}-public"
  }
}

resource "aws_network_acl_rule" "public_egress_all_ipv4" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 0
  network_acl_id = aws_network_acl.public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 60
  to_port        = 0
}

resource "aws_network_acl_rule" "public_egress_all_ipv6" {
  count           = var.network_enable_ipv6 ? 1 : 0
  egress          = true
  from_port       = 0
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.public.id
  protocol        = "-1"
  rule_action     = "allow"
  rule_number     = 65
  to_port         = 0
}

resource "aws_network_acl_rule" "public_ingress_internal_all_ipv4" {
  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 0
  network_acl_id = aws_network_acl.public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 50
}

resource "aws_network_acl_rule" "public_ingress_internal_all_ipv6" {
  count           = var.network_enable_ipv6 ? 1 : 0
  egress          = false
  from_port       = 0
  ipv6_cidr_block = "::/0"
  network_acl_id  = aws_network_acl.public.id
  protocol        = "-1"
  rule_action     = "allow"
  rule_number     = 55
}
