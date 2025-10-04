locals {
  subnet_ipa          = "10.252.3.0/24"

  aclrules_access_ipa = {
    start_idx = 1300
    rules     = [
      {
        description  = "IPA http"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "IPA https"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "443"
        traffic_type = "egress"
      },
      {
        description  = "IPA ldap"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "389"
        traffic_type = "egress"
      },
      {
        description  = "IPA ldaps"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "636"
        traffic_type = "egress"
      },
      {
        description  = "kerberos udp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "88"
        traffic_type = "egress"
      },
      {
        description  = "kpasswd udp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "464"
        traffic_type = "egress"
      },
      {
        description  = "kerberos tcp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "88"
        traffic_type = "egress"
      },
      {
        description  = "kpasswd tcp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "464"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ipa = {
    start_idx = 1350
    rules     = [
      {
        description  = "IPA http"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "80"
        traffic_type = "ingress"
      },
      {
        description  = "IPA https"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "443"
        traffic_type = "ingress"
      },
      {
        description  = "IPA ldap"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "389"
        traffic_type = "ingress"
      },
      {
        description  = "IPA ldaps"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "636"
        traffic_type = "ingress"
      },
      {
        description  = "kerberos udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "88"
        traffic_type = "ingress"
      },
      {
        description  = "kpasswd udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        icmp_type    = null
        icmp_code    = null
        port         = "464"
        traffic_type = "ingress"
      },
      {
        description  = "kerberos tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "88"
        traffic_type = "ingress"
      },
      {
        description  = "kpasswd tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "464"
        traffic_type = "ingress"
      }
    ]
  }

  aclrules_ipa_all = concat(local.aclrules_common, [ local.aclrules_ipa, local.aclrules_access_secureproxy, local.aclrules_access_ldapproxy ])

}

resource "cloudstack_network_acl" "ipa" {
  name   = "ipa"
  vpc_id = cloudstack_vpc.infra_vpc.id
}

resource "cloudstack_network_acl_rule" "ipa" {
  acl_id  = cloudstack_network_acl.ipa.id
  managed = true

  dynamic "rule" {
    for_each = flatten([
        for list in local.aclrules_ipa_all : [
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

resource "cloudstack_network" "ipa" {
  name             = "ipa"
  vpc_id           = cloudstack_vpc.infra_vpc.id
  cidr             = local.subnet_ipa
  network_offering = var.cloudstack_networkoffering_isolated
  zone             = var.cloudstack_zone
  project          = var.cloudstack_project
  acl_id           = cloudstack_network_acl.ipa.id
}
