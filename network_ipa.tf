locals {
  subnet_ipa = "10.252.3.0/24"
  aclrules_access_ipa = [
    {
      description  = "IPA http and https"
      action       = "allow"
      cidr_list    = [ local.subnet_ipa ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "80", "443" ]
      traffic_type = "egress"
    },
    {
      description  = "IPA ldap and ldaps"
      action       = "allow"
      cidr_list    = [ local.subnet_ipa ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "389", "636" ]
      traffic_type = "egress"
    },
    {
      description  = "kerberos and kpasswd udp"
      action       = "allow"
      cidr_list    = [ local.subnet_ipa ]
      protocol     = "udp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "88", "464" ]
      traffic_type = "egress"
    },
    {
      description  = "kerberos and kpasswd tcp"
      action       = "allow"
      cidr_list    = [ local.subnet_ipa ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "88", "464" ]
      traffic_type = "egress"
    }
  ]
}

resource "cloudstack_network_acl" "ipa" {
  name   = "ipa"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "ipa" {
  acl_id  = cloudstack_network_acl.ipa.id
  managed = true

  dynamic "rule" {
    for_each = local.aclrules_access_ipa
    content {
      description  = rule.value.description
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = rule.value.protocol
      ports        = rule.value.ports
      traffic_type = "ingress"
    }
  }

  dynamic "rule" {
    for_each = concat(local.aclrules_common, local.aclrules_access_secureproxy, local.aclrules_access_ldapproxy)
    content {
      description  = rule.value.description
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

resource "cloudstack_network" "ipa" {
  name             = "ipa"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_ipa
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.ipa.id
}
