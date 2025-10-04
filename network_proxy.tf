locals {
  subnet_proxy   = "10.252.5.0/24"
  ip_secureproxy = "10.252.5.11/24"
  ip_cacheproxy  = "10.252.5.21/24"
  ip_gitproxy    = "10.252.5.31/24"


  aclrules_access_secureproxy = {
    start_idx = 1500
    rules     = [
      {
        description  = "proxy secureproxy"
        action       = "allow"
        cidr_list    = [ local.ip_secureproxy ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "8080"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_access_cacheproxy = {
    start_idx = 1510
    rules     = [
      {
        description  = "proxy cacheproxy"
        action       = "allow"
        cidr_list    = [ local.ip_cacheproxy ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "8080"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_access_gitproxy = {
    start_idx = 1520
    rules     = [
      {
        description  = "proxy gitproxy"
        action       = "allow"
        cidr_list    = [ local.ip_gitproxy ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "8080"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_proxy = {
    start_idx = 1550
    rules     = [
      {
        description  = "Allow ingress proxy"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "8080"
        traffic_type = "ingress"
      },
      {
        description  = "Allow egress to world on 80"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "Allow egress to world on 443"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "443"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_proxy_all = concat(local.aclrules_common, [ local.aclrules_proxy ])
}

resource "cloudstack_network_acl" "proxy" {
  name   = "proxy"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "proxy" {
  acl_id  = cloudstack_network_acl.proxy.id
  managed = true

  dynamic "rule" {
    for_each = flatten([
        for list in local.aclrules_proxy_all : [
          for rule in list.rules : {
            rule_number  = "${list.start_idx + index(list.rules, rule) + 1}"
            description  = rule.description
            action       = rule.action
            cidr_list    = rule.cidr_list
            protocol     = rule.protocol
            icmp_type    = rule.icmp_type
            icmp_code    = rule.icmp_code
            port         = rule.port
            traffic_type = rule.traffic_type
          }
        ]
      ])
    content {
      rule_number  = rule.value.rule_number
      description  = "${rule.value.description}: ${rule.value.action} ${rule.value.traffic_type}"
      action       = rule.value.action
      cidr_list    = rule.value.cidr_list
      protocol     = rule.value.protocol
      icmp_type    = rule.value.icmp_type
      icmp_code    = rule.value.icmp_code
      ports        = [ rule.value.port ]
      traffic_type = rule.value.traffic_type
    }
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
