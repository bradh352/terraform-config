locals {
  aclrules_deny_egress = [
    {
      description  = "deny egress by default"
      action       = "deny"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = "all"
      icmp_type    = null
      icmp_code    = null
      ports        = null
      traffic_type = "egress"
    }
  ]
  aclrules_common    = concat(local.aclrules_deny_egress, local.aclrules_access_dns, local.aclrules_access_ipa, local.aclrules_access_su, local.aclrules_access_mirror, local.aclrules_access_ntp, local.aclrules_access_mirror)
  aclrules_bootstrap = [
    {
      description  = "bootstrap rule to allow dns:tcp, http, https anywhere"
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "53", "80", "443" ]
      traffic_type = "egress"
    },
    {
      description  = "bootstrap rule to allow dns:udp anywhere"
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = "udp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "53" ]
      traffic_type = "egress"
    }
  ]
}
