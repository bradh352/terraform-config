locals {
  subnet_ntp = "10.252.4.0/24"
  aclrules_access_ntp = [
    {
      action       = "allow"
      cidr_list    = [ local.subnet_ntp ]
      protocol     = "udp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "123" ]
      traffic_type = "egress"
    }
  ]
}

resource "cloudstack_network_acl" "ntp" {
  name   = "ntp"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "ntp" {
  acl_id  = cloudstack_network_acl.ntp.id
  managed = true

  dynamic "rule" {
    for_each = local.aclrules_access_ntp
    content {
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = rule.value.protocol
      ports        = rule.value.ports
      traffic_type = "egress"
    }
  }
  dynamic "rule" {
    for_each = local.aclrules_access_ntp
    content {
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

resource "cloudstack_network" "ntp" {
  name             = "ntp"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_ntp
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.ntp.id
}
