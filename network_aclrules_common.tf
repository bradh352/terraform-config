locals {
  aclrules_bootstrap = {
    start_idx = 65000
    rules     = [
      {
        description  = "bootstrap rule to allow http"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        ports        = "80"
        traffic_type = "egress"
      },
      {
        description  = "bootstrap rule to allow https"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        port         = "443"
        traffic_type = "egress"
      },
      {
        description  = "bootstrap rule to allow dns:tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        icmp_type    = null
        icmp_code    = null
        ports        = "53"
        traffic_type = "egress"
      },
      {
        description  = "bootstrap rule to allow dns:udp anywhere"
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
  aclrules_deny_all = {
    start_idx = 65500
    rules = [
      {
        description  = "deny egress by default"
        rule_number  = 65535
        action       = "deny"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "all"
        icmp_type    = null
        icmp_code    = null
        traffic_type = "egress"
      }
    ]
  }
  aclrules_common = [ local.aclrules_access_dns, local.aclrules_access_ipa, local.aclrules_access_su, local.aclrules_access_mirror, local.aclrules_access_ntp, local.aclrules_deny_all ]
  # var.bootstrap ? local.aclrules_bootstrap : null,
}
