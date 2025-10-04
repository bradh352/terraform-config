locals {
  subnet_proxy   = "10.252.5.0/24"
  ip_secureproxy = "10.252.5.11/24"
  ip_cacheproxy  = "10.252.5.21/24"
  ip_gitproxy    = "10.252.5.31/24"
  aclrules_access_secureproxy = [
    {
      description  = "proxy secureproxy"
      action       = "allow"
      cidr_list    = [ local.ip_secureproxy ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "8080" ]
      traffic_type = "egress"
    }
  ]
  aclrules_access_cacheproxy = [
    {
      description  = "proxy cacheproxy"
      action       = "allow"
      cidr_list    = [ local.ip_cacheproxy ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "8080" ]
      traffic_type = "egress"
    }
  ]
  aclrules_access_gitproxy = [
    {
      description  = "proxy gitproxy"
      action       = "allow"
      cidr_list    = [ local.ip_gitproxy ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "8080" ]
      traffic_type = "egress"
    }
  ]
}

resource "cloudstack_network_acl" "proxy" {
  name   = "proxy"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "proxy" {
  acl_id  = cloudstack_network_acl.proxy.id
  managed = true

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

  rule {
    #description  = "Allow ingress proxy"
    action       = "allow"
    cidr_list    = [ "0.0.0.0/0" ]
    protocol     = "tcp"
    ports        = [ "8080" ]
    traffic_type = "ingress"
  }
  rule {
    #description  = "Allow egress to world on 80 and 443"
    action       = "allow"
    cidr_list    = [ "0.0.0.0/0" ]
    protocol     = "tcp"
    ports        = [ "80", "443" ]
    traffic_type = "egress"
  }
}

resource "cloudstack_network" "proxy" {
  name             = "proxy"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_proxy
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.proxy.id
}
