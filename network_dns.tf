locals {
  subnet_dns          = "10.252.1.0/24"

  aclrules_access_dns = {}
    start_idx = 1100
    rules     = [
      {
        description  = "dns:tcp"
        action       = "allow"
        cidr_list    = [ local.subnet_dns ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "egress"
      },
      {
        description  = "dns:udp"
        action       = "allow"
        cidr_list    = [ local.subnet_dns ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_dns = {
    start_idx = 1150
    rules     = [
      {
        description  = "dns:tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "ingress"
      },
      {
        description  = "dns:udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "ingress"
      },
      {
        description  = "dns:tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "egress"
      },
      {
        description  = "dns:udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "53"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_dns_all = concat(local.aclrules_common, [ local.aclrules_dns ])
}

resource "cloudstack_network_acl" "dns" {
  name   = "dns"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "dns" {
  acl_id  = cloudstack_network_acl.dns.id
  managed = true

  dynamic "rule" {
    for_each = flatten([
        for list in local.aclrules_dns_all : [
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

resource "cloudstack_network" "dns" {
  name             = "dns"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_dns
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.dns.id
}
