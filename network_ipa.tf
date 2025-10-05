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
        port         = "80"
        traffic_type = "egress"
      },
      {
        description  = "IPA https"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        port         = "443"
        traffic_type = "egress"
      },
      {
        description  = "IPA ldap"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        port         = "389"
        traffic_type = "egress"
      },
      {
        description  = "IPA ldaps"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        port         = "636"
        traffic_type = "egress"
      },
      {
        description  = "kerberos udp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "udp"
        port         = "88"
        traffic_type = "egress"
      },
      {
        description  = "kpasswd udp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "udp"
        port         = "464"
        traffic_type = "egress"
      },
      {
        description  = "kerberos tcp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        port         = "88"
        traffic_type = "egress"
      },
      {
        description  = "kpasswd tcp"
        action       = "allow"
        cidr_list    = [ local.subnet_ipa ]
        protocol     = "tcp"
        port         = "464"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ipa = {
    start_idx = 30000
    rules     = [
      {
        description  = "IPA http"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "80"
        traffic_type = "ingress"
      },
      {
        description  = "IPA https"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "443"
        traffic_type = "ingress"
      },
      {
        description  = "IPA ldap"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "389"
        traffic_type = "ingress"
      },
      {
        description  = "IPA ldaps"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "636"
        traffic_type = "ingress"
      },
      {
        description  = "kerberos udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "88"
        traffic_type = "ingress"
      },
      {
        description  = "kpasswd udp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "udp"
        port         = "464"
        traffic_type = "ingress"
      },
      {
        description  = "kerberos tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "88"
        traffic_type = "ingress"
      },
      {
        description  = "kpasswd tcp"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
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

module "network_acl_ipa" {
  source    = "./modules/cloudstack_network_acl"
  acl_id    = cloudstack_network_acl.ipa.id
  managed   = true
  bootstrap = var.bootstrap
  rulelist  = local.aclrules_ipa_all
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
