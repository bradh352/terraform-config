locals {
  subnet_ldapproxy = "10.252.6.0/24"
  aclrules_access_ldapproxy = [
    {
      description  = "ldap and ldaps"
      action       = "allow"
      cidr_list    = [ local.subnet_ldapproxy ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "389", "636" ]
      traffic_type = "egress"
    }
  ]
}

resource "cloudstack_network_acl" "ldapproxy" {
  name   = "ldapproxy"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "ldapproxy" {
  acl_id  = cloudstack_network_acl.ldapproxy.id
  managed = true

  dynamic "rule" {
    for_each = local.aclrules_access_ldapproxy
    content {
      #description  = rule.value.description
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = rule.value.protocol
      ports        = rule.value.ports
      traffic_type = "ingress"
    }
  }

  dynamic "rule" {
    for_each = local.aclrules_common
    content {
      #description  = rule.value.description
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

resource "cloudstack_network" "ldapproxy" {
  name             = "ldapproxy"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_ldapproxy
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.ldapproxy.id
}
