######################################################################
# Provides Information for Firewall Resources Created by this Module #
######################################################################

output "firewall_bastion_id" {
  description = "ID of the Bastion VPC Security Group [Firewall]"
  value       = aws_security_group.bastion.id
}

output "firewall_default_id" {
  description = "ID of the Default VPC Security Group [Firewall]"
  value       = aws_default_security_group.main.id
}

#####################################################################
# Provides Information for Network Resources Created by this Module #
#####################################################################

output "network_cidrs" {
  description = "List of CIDR Blocks Associated w/ this Network"
  value       = local.network_cidrs
}

output "network_id" {
  description = "Dynamically-Assigned Identifier (ID) for this Network"
  value       = aws_vpc.main.id
}

output "network_name" {
  description = "Name Assigned to this Network During Creation"
  value       = aws_vpc.main.tags_all["Name"]
}

#####################################################################
# Provides Information for Routing Resources Created by this Module #
#####################################################################

output "routers_private" {
  description = "List of Objects Representing Private Router Attributes"

  value = [for router in aws_route_table.private : {
    arn  = router.arn
    id   = router.id
    name = router.tags_all["Name"]
  }]
}

output "routers_public" {
  description = "List of Objects Representing Public Router Attributes"

  value = [for router in aws_route_table.public : {
    arn  = router.arn
    id   = router.id
    name = router.tags_all["Name"]
  }]
}

####################################################################
# Provides Information for Subnet Resources Created by this Module #
####################################################################

output "subnets_private" {
  description = "List of Objects Representing Private Subnet Attributes"

  value = [for subnet in aws_subnet.private : {
    cidr_block = subnet.cidr_block
    id         = subnet.id
    name       = subnet.tags_all["Name"]
  }]
}

output "subnets_public" {
  description = "List of Objects Representing Public Subnet Attributes"

  value = [for subnet in aws_subnet.public : {
    cidr_block = subnet.cidr_block
    id         = subnet.id
    name       = subnet.tags_all["Name"]
  }]
}
