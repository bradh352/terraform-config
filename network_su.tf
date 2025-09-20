locals {
  subnet_su = "10.55.99.0/24"
  aclrules_access_su = [
    {
      action       = "allow"
      cidr_list    = [ local.subnet_su ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "22" ]
      traffic_type = "ingress"
    }
  ]
}

resource "cloudstack_network_acl" "su" {
  name   = "su"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "su" {
  acl_id  = cloudstack_network_acl.su.id
  managed = true

  # Disallow other VPC subnets from SSHing to network
  rule {
    action       = "deny"
    cidr_list    = [ local.subnet_vpc ]
    protocol     = "tcp"
    ports        = [ "22" ]
    traffic_type = "ingress"
  }

  # Allow the rest of the world to SSH, since this will have a bastion host.
  rule {
    action       = "allow"
    cidr_list    = [ "0.0.0.0/0" ]
    protocol     = "tcp"
    ports        = [ "22" ]
    traffic_type = "ingress"
  }

  # This host is allowed to SSH anywhere in the VPC
  rule {
    action       = "allow"
    cidr_list    = [ local.subnet_vpc ]
    protocol     = "tcp"
    ports        = [ "22" ]
    traffic_type = "egress"
  }

  # Bootstrap-only rules
  dynamic "rule" {
    for_each = var.bootstrap ? local.aclrules_bootstrap : []
    content {
      action       = rule.value.action
      cidr_list    = rule.value.cidr_list
      protocol     = rule.value.protocol
      icmp_type    = rule.value.icmp_type
      icmp_code    = rule.value.icmp_code
      ports        = rule.value.ports
      traffic_type = rule.value.traffic_type
    }
  }

  # Allow access to resources provided by VPC
  dynamic "rule" {
    for_each = local.aclrules_common
    content {
      action       = rule.value.action
      cidr_list    = rule.value.cidr_list
      protocol     = rule.value.protocol
      icmp_type    = rule.value.icmp_type
      icmp_code    = rule.value.icmp_code
      ports        = rule.value.ports
      traffic_type = rule.value.traffic_type
    }
  }
}

resource "cloudstack_network" "su" {
  name             = "su"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_su
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.su.id
}

resource "cloudstack_ipaddress" "bastion" {
  vpc_id = cloudstack_vpc.infra_vpc.id
  zone   = var.cloudstack_zone
}

resource "cloudstack_port_forward" "bastion" {
  ip_address_id = cloudstack_ipaddress.bastion.id

  forward {
    protocol           = "tcp"
    private_port       = 22
    public_port        = 5022
    virtual_machine_id = module.instance_bastion.id
  }
}
