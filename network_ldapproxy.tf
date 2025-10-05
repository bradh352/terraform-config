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
        port         = "389"
        traffic_type = "egress"
      },
      {
        description  = "ldaps"
        action       = "allow"
        cidr_list    = [ local.subnet_ldapproxy ]
        protocol     = "tcp"
        port         = "636"
        traffic_type = "egress"
      }
    ]
  }

  aclrules_ldapproxy = {
    start_idx = 30000
    rules     = [
      {
        description  = "ldap"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "389"
        traffic_type = "ingress"
      },
      {
        description  = "ldaps"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "636"
        traffic_type = "ingress"
      },
      {
        description  = "ldap"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
        port         = "389"
        traffic_type = "egress"
      },
      {
        description  = "ldaps"
        action       = "allow"
        cidr_list    = [ "0.0.0.0/0" ]
        protocol     = "tcp"
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

module "network_acl_ldapproxy" {
  source    = "./modules/cloudstack_network_acl"
  acl_id    = cloudstack_network_acl.ldapproxy.id
  managed   = true
  bootstrap = var.bootstrap
  rulelist  = local.aclrules_ldapproxy_all
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
