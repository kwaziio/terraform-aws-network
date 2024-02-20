#############################################################
# Updates Default VPC Security Group [Application Firewall] #
#############################################################

resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.network_tags_name}-default"
  }
}

resource "aws_vpc_security_group_egress_rule" "default_all_ipv4" {
  cidr_ipv4         = "0.0.0.0/0"
  count             = var.network_enable_default_security_group ? 1 : 0
  description       = "Allows All Outbound Access to IPv4 Destinations"
  from_port         = 0
  ip_protocol       = "tcp"
  security_group_id = aws_default_security_group.main.id
  to_port           = 0

  tags = {
    Name = "${aws_default_security_group.main.name}-egress-all-ipv4"
  }
}

resource "aws_vpc_security_group_egress_rule" "default_all_ipv6" {
  cidr_ipv6         = "::/0"
  count             = var.network_enable_default_security_group ? 1 : 0
  description       = "Allows All Outbound Access to IPv6 Destinations"
  from_port         = 0
  ip_protocol       = "tcp"
  security_group_id = aws_default_security_group.main.id
  to_port           = 0

  tags = {
    Name = "${aws_default_security_group.main.name}-egress-all-ipv6"
  }
}

resource "aws_vpc_security_group_ingress_rule" "default_rdp_bastion" {
  count                        = var.network_enable_default_security_group ? 1 : 0
  description                  = "Allows RDP Connections from Bastion Host(s)"
  from_port                    = var.network_default_rdp_port
  ip_protocol                  = "tcp"
  security_group_id            = aws_default_security_group.main.id
  referenced_security_group_id = aws_security_group.bastion.id
  to_port                      = var.network_default_rdp_port

  tags = {
    Name = "${aws_default_security_group.main.name}-ingress-rdp-bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "default_ssh_bastion" {
  count                        = var.network_enable_default_security_group ? 1 : 0
  description                  = "Allows SSH Connections from Bastion Host(s)"
  from_port                    = var.network_default_ssh_port
  ip_protocol                  = "tcp"
  security_group_id            = aws_default_security_group.main.id
  referenced_security_group_id = aws_security_group.bastion.id
  to_port                      = var.network_default_ssh_port

  tags = {
    Name = "${aws_default_security_group.main.name}-ingress-ssh-bastion"
  }
}

##################################################################
# Creates Bastion Host VPC Security Group [Application Firewall] #
##################################################################

resource "aws_security_group" "bastion" {
  description = "Firewall Rules Associated w/ Bastion Host Resources"
  name        = "${var.network_tags_name}-bastion"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.network_tags_name}-bastion"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_all_ipv4" {
  cidr_ipv4         = var.network_egress_cidr_block_ipv4
  ip_protocol       = "-1"
  security_group_id = aws_security_group.bastion.id

  tags = {
    Name = "${aws_security_group.bastion.name}-egress-all-ipv4"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_all_ipv6" {
  cidr_ipv6         = var.network_egress_cidr_block_ipv6
  ip_protocol       = "-1"
  security_group_id = aws_security_group.bastion.id

  tags = {
    Name = "${aws_security_group.bastion.name}-egress-all-ipv6"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_rdp_ipv4" {
  cidr_ipv4         = var.network_trusted_ipv4_cidrs[count.index]
  count             = length(var.network_trusted_ipv4_cidrs)
  from_port         = var.network_default_rdp_port
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.bastion.id
  to_port           = var.network_default_rdp_port

  tags = {
    Name = "${aws_security_group.bastion.name}-ingress-rdp-ipv4"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh_ipv4" {
  cidr_ipv4         = var.network_trusted_ipv4_cidrs[count.index]
  count             = length(var.network_trusted_ipv4_cidrs)
  from_port         = var.network_default_ssh_port
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.bastion.id
  to_port           = var.network_default_ssh_port

  tags = {
    Name = "${aws_security_group.bastion.name}-ingress-ssh-ipv4"
  }
}
