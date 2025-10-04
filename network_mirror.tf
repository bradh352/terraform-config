locals {
  subnet_mirror = "10.252.2.0/24"
  aclrules_access_mirror = [
    {
      description  = "http and https mirror"
      action       = "allow"
      cidr_list    = [ local.subnet_mirror ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "80", "443" ]
      traffic_type = "egress"
    }
  ]
}

resource "cloudstack_network_acl" "mirror" {
  name   = "mirror"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "mirror" {
  acl_id  = cloudstack_network_acl.mirror.id
  managed = true

  dynamic "rule" {
    for_each = concat(local.aclrules_common, local.aclrules_access_secureproxy)
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
  rule {
    #description  = "allow to public http, https, rsync"
    action       = "allow"
    cidr_list    = [ "0.0.0.0/0" ]
    protocol     = "tcp"
    ports        = [ "80", "443", "873" ]
    traffic_type = "egress"
  }
  dynamic "rule" {
    for_each = local.aclrules_access_mirror
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
    for_each = concat(local.aclrules_common, local.aclrules_access_secureproxy)
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

resource "cloudstack_network" "mirror" {
  name             = "mirror"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_mirror
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.mirror.id
}
