locals {
  aclrules_common    = concat(local.aclrules_access_dns, local.aclrules_access_ipa, local.aclrules_access_su, local.aclrules_access_mirror, local.aclrules_access_ntp, aclrules_access_mirror)
  aclrules_bootstrap = [
    {
      action       = "allow"
      cidr_list    = [ "0.0.0.0/0" ]
      protocol     = "tcp"
      icmp_type    = null
      icmp_code    = null
      ports        = [ "53", "80", "443" ]
      traffic_type = "egress"
    },
    {
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
