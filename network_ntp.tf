locals {
  subnet_ntp = "10.252.4.0/24"
  aclrules_access_ntp = {
    start_idx = 1400
    rules     = [
      {
        description  = "ntp"
        action       = "allow"
        cidr_list    = [ local.subnet_ntp ]
        protocol     = "udp"
        port         = "123"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ntp = {
    start_idx = 30000
    rules     = [
      {
        description  = "ntp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "123"
        traffic_type = "egress"
      },
      {
        description  = "ntp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "123"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_ntp_all = concat(local.aclrules_common, [ local.aclrules_ntp ])
}

resource "cloudstack_network_acl" "ntp" {
  name   = "ntp"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "ntp" {
  acl_id  = cloudstack_network_acl.ntp.id
  managed = true

  dynamic "rule" {
    for_each = flatten([
        for list in local.aclrules_dns_all : [
          for rule in list.rules : {
            rule_number  = "${list.start_idx + index(list.rules, rule) + 1}"
            description  = try(rule.description, "")
            action       = rule.action
            cidr_list    = rule.cidr_list
            protocol     = rule.protocol
            icmp_type    = try(rule.icmp_type, null)
            icmp_code    = try(rule.icmp_code, null)
            port         = try(rule.port, null)
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
      ports        = rule.value.port == null ? null : [ rule.value.port ]
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
