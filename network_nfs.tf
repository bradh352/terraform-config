locals {
  subnet_nfs          = "10.252.7.0/24"

  aclrules_access_nfs = {
    start_idx = 1700
    rules     = [
      {
        description  = "nfs"
        action       = "allow"
        cidr_list    = [ local.subnet_nfs ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "2049"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_nfs = {
    start_idx = 1750
    rules     = [
      {
        description  = "nfs"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "2049"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_nfs_all = concat(local.aclrules_common, [ local.aclrules_nfs ])
}

resource "cloudstack_network_acl" "nfs" {
  name   = "nfs"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "nfs" {
  acl_id  = cloudstack_network_acl.nfs.id
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
      ports        = try([ rule.value.port ], null)
      traffic_type = rule.value.traffic_type
    }
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
