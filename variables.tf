###########################################################
# AWS Virtual Private Cloud (VPC) [Network] Configuration #
###########################################################

variable "network_default_rdp_port" {
  default     = 3389
  description = "Default RDP Port to Leverage Throughout the Created Network"
  type        = number
}

variable "network_default_ssh_port" {
  default     = 22
  description = "Default SSH Port to Leverage Throughout the Created Network"
  type        = number
}

variable "network_egress_cidr_block_ipv4" {
  default     = "0.0.0.0/0"
  description = "IPv4 CIDR Block to Consider When Allowing Outbound Traffic to External Destinations"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.network_egress_cidr_block_ipv4))
    error_message = "Value Must be in Valid IPv4 CIDR Notation (RFC 4632 3.1)"
  }
}

variable "network_egress_cidr_block_ipv6" {
  default     = "::/0"
  description = "IPv6 CIDR Block to Consider When Allowing Outbound Traffic to External Destinations"
  type        = string
}

variable "network_enable_default_security_group" {
  default     = true
  description = "'true' if Default Security Group Should Support Standard Firewall Rules"
  type        = bool
}

variable "network_enable_dns_hostnames" {
  default     = true
  description = "'true' if DNS Hostnames Should be Generated for Instances in the Created Network"
  type        = bool
}

variable "network_enable_dns_support" {
  default     = true
  description = "'true' if DNS Support Should be Enabled for the Created Network"
  type        = bool
}

variable "network_enable_internet" {
  default     = true
  description = "'true' if Internet Connectivity Should be Possible for the Created Network"
  type        = bool
}

variable "network_enable_ipv6" {
  default     = true
  description = "'true' if IPv6 Support Should be Enabled for the Created Network"
  type        = bool
}

variable "network_enable_metrics" {
  default     = true
  description = "'true' if Network Metrics Should be Enabled for the Created Network"
  type        = bool
}

variable "network_enable_nat" {
  default     = false
  description = "'true' if Network Address Translation (NAT) Gateways Should be Created"
  type        = bool
}

variable "network_instance_tenancy" {
  default     = "default"
  description = "Default Tenancy Option for All Instances Deployed to the Created Network"
  type        = string

  validation {
    condition     = contains(["default", "dedicated"], var.network_instance_tenancy)
    error_message = "Value Must be Either 'default' or 'dedicated'"
  }
}

variable "network_primary_cidr_block" {
  description = "Primary IPv4 CIDR Block to Associate w/ the Created Network"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.network_primary_cidr_block))
    error_message = "Value Must be in Valid IPv4 CIDR Notation (RFC 4632 3.1)"
  }
}

variable "network_secondary_cidr_blocks" {
  default     = []
  description = "List of Secondary IPv4 CIDR Blocks to Associate w/ the Created Network"
  type        = list(string)

  validation {
    condition     = length(var.network_secondary_cidr_blocks) < 5
    error_message = "Must Declare 4 or Less Secondary CIDR Blocks"
  }
}

variable "network_tags_name" {
  description = "Name to Associate w/ the Created Network"
  type        = string
}

variable "network_trusted_ipv4_cidrs" {
  default     = []
  description = "IPv4 CIDR Block(s) Permitted to Access Bastion Host Resources"
  type        = list(string)
}

##################################################################
# AWS Virtual Private Cloud (VPC) [Network] Subnet Configuration #
##################################################################

variable "subnets_private" {
  default     = []
  description = "List of Private Subnets w/ Assigned Name and IPv4 CIDR Values"

  type = list(object({
    cidr = string
    name = string
    zone = string
  }))
}

variable "subnets_private_tags" {
  default     = {}
  description = "Additional Tags to Add to All Private Subnets"
  type        = map(string)
}

variable "subnets_public" {
  default     = []
  description = "List of Public Subnets w/ Assigned Name and IPv4 CIDR Values"

  type = list(object({
    cidr = string
    name = string
    zone = string
  }))
}

variable "subnets_public_tags" {
  default     = {}
  description = "Additional Tags to Add to All Public Subnets"
  type        = map(string)
}
