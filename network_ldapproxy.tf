locals {
  subnet_ldapproxy          = "10.252.6.0/24"

  aclrules_access_ldapproxy = {
    start_idx = 1600
    rules     = [
      {
        description  = "ldap"
        action       = "allow"
        cidr_list    = [ local.subnet_ldapproxy ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "389"
        traffic_type = "egress"
      },
      {
        description  = "ldaps"
        action       = "allow"
        cidr_list    = [ local.subnet_ldapproxy ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "636"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ldapproxy = {
    start_idx = 1650
    rules     = [
      {
        description  = "ldap"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "389"
        traffic_type = "ingress"
      },
      {
        description  = "ldaps"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "636"
        traffic_type = "ingress"
      },
      {
        description  = "ldap"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "389"
        traffic_type = "egress"
      },
      {
        description  = "ldaps"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "636"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ldapproxy_all = concat(local.aclrules_common, [ local.aclrules_access_secureproxy, local.aclrules_ldapproxy ])
}

resource "cloudstack_network_acl" "ldapproxy" {
  name   = "ldapproxy"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "ldapproxy" {
  acl_id  = cloudstack_network_acl.ldapproxy.id
  managed = true

  dynamic "rule" {
    for_each = flatten([
        for list in local.aclrules_ldapproxy_all : [
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

resource "cloudstack_network" "ldapproxy" {
  name             = "ldapproxy"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_ldapproxy
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.ldapproxy.id
}
