locals {
  aclrules_common    = concat(local.aclrules_access_dns, local.aclrules_access_ipa, local.aclrules_access_su, local.aclrules_access_mirror, local.aclrules_access_ntp, local.aclrules_access_mirror)
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
  aclrules_common_list = [
    {
      start_idx = 1
      rules     = local.aclrules_access_dns
    },
    {
      start_idx = 100
      rules     = local.aclrules_access_ipa
    },
    {
      start_idx = 200
      rules     = local.aclrules_access_su
    },
    {
      start_idx = 300
      rules     = local.aclrules_access_mirror
    },
    {
      start_idx = 400
      rules     = local.aclrules_access_ntp
    }
  ]
}
