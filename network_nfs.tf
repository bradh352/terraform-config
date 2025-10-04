locals {
  subnet_nfs = "10.252.7.0/24"
  aclrules_access_nfs = [
    {
      description  = "nfs"
      action       = "allow"
      cidr_list    = [ local.subnet_nfs ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "2049" ]
      traffic_type = "egress"
    }
  ]
}

resource "cloudstack_network_acl" "nfs" {
  name   = "nfs"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "nfs" {
  acl_id  = cloudstack_network_acl.nfs.id
  managed = true

  dynamic "rule" {
    for_each = local.aclrules_common
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

  dynamic "rule" {
    for_each = local.aclrules_access_nfs
    content {
      description  = rule.value.description
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = rule.value.protocol
      ports        = rule.value.ports
      traffic_type = "ingress"
    }
  }
  # Deny all others
  rule {
    description  = "deny egress by default"
    rule_number  = 99999
    action       = "deny"
    cidr_list    = [ "0.0.0.0/0" ]
    protocol     = "all"
    traffic_type = "egress"
  }
}

resource "cloudstack_network" "nfs" {
  name             = "nfs"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_nfs
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.nfs.id
}
