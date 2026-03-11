locals {
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
  aclrules_deny_something = {
    start_idx = 65400
    rules = [
      {
        description  = "deny egress by default"
        action       = "deny"
        cidr_list    = [ "1.2.3.4/32" ]
        protocol     = "all"
        icmp_type    = null
        icmp_code    = null
        traffic_type = "egress"
      }
    ]
  }
  aclrules_common_nodefaultdeny = [ local.aclrules_access_dns, local.aclrules_access_ipa, local.aclrules_access_su, local.aclrules_access_mirror, local.aclrules_access_ntp ]
  aclrules_common = concat(local.aclrules_common_nodefaultdeny, [ local.aclrules_deny_something, local.aclrules_deny_all ])
}
